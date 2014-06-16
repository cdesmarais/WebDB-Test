if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_SetEmailPreferences]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[UserSvc_SetEmailPreferences]
GO

CREATE PROCEDURE [dbo].UserSvc_SetEmailPreferences
(
	@GlobalPersonId bigint,
	@Spotlight bit = null,
	@Insider bit = null,
	@DinersChoice bit = null,
	@NewHot bit = null,
	@RestaurantWeek bit = null,
	@Promotional bit = null,
	@Product bit = null
)
AS

SET NOCOUNT ON

DECLARE @CustID int
DECLARE @CallerID int
DECLARE @MetroID int
DECLARE @DBError int
DECLARE @Action nvarchar(3000)
DECLARE @ProcName nvarchar(1000)
SET @ProcName = 'UserSvc_SetEmailPreferences'

BEGIN TRAN

SET @Action = 'Get user information using Global Person ID'
select
	@CustID = cust.CustID, 
	@CallerID = cal.CallerID,
	@MetroID = (case when cal.CallerID IS Not null then cal.MetroAreaID else cust.MetroAreaID end)
from GlobalPerson gp
left outer join Customer cust on cust.CustID = gp.CustID
left outer join Caller cal on cal.CallerID = gp.CallerID
where gp._GlobalPersonID = @GlobalPersonId


SET @Action = 'update user email preferences'

-- Need to delete all rows for that user until we only get one row for each user.
-- This is because the consumer site was supporting setting preferences in different metros, neighborhoods.
delete from UserOptIn where ((CustID = @CustID and CallerID is null) or (CustID is null and CallerID = @CallerID)) and MetroAreaID <> @MetroID

MERGE INTO UserOptin as uo
using (
	select 
		isnull(u.CustID, def.CustID) as CustID, isnull(u.CallerID, def.CallerID) as CallerID,
		isnull(Spotlight, @Spotlight) as Spotlight,
		isnull(Insider, @Insider) as Insider,
		isnull(DinersChoice, @DinersChoice) as DinersChoice,
		isnull(NewHot, @NewHot) as NewHot,
		isnull(RestaurantWeek, @RestaurantWeek) as RestaurantWeek,
		isnull(Promotional, @Promotional) as Promotional,
		isnull(Product, @Product) as Product
	from (select @CustID as CustID, @CallerID as CallerID) def
	left outer join UserOptin u on u.CustID = def.CustID and u.CallerID = def.CallerID
) as cur
on (uo.CustID is null and uo.CallerID = cur.CallerID) or (uo.CustID = cur.CustID and uo.CallerID is null)
WHEN MATCHED THEN
	UPDATE SET 
		Spotlight = (case when @Spotlight is not null then @Spotlight else uo.Spotlight end),
		Insider = (case when @Insider is not null then @Insider else uo.Insider end),
		DinersChoice = (case when @DinersChoice is not null then @DinersChoice else uo.DinersChoice end),
		NewHot = (case when @NewHot is not null then @NewHot else uo.NewHot end),
		RestaurantWeek = (case when @RestaurantWeek is not null then @RestaurantWeek else uo.RestaurantWeek end),
		Promotional = (case when @Promotional is not null then @Promotional else uo.Promotional end),
		Product = (case when @Product is not null then @Product else uo.Product end),
		UpdatedDtUTC = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT 
	(
		CustID,	CallerID, 
		MetroAreaID, MacroID, NeighborhoodID,
		Spotlight, Insider, DinersChoice, NewHot, RestaurantWeek, Promotional, Product, 
		UpdatedDtUTC
	)
	VALUES
	(
		@CustID, @CallerID,
		@MetroID, null, null,
		case when @Spotlight is not null then @Spotlight else 0 end,
		case when @Insider is not null then @Insider else 0 end,
		case when @DinersChoice is not null then @DinersChoice else 0 end,
		case when @NewHot is not null then @NewHot else 0 end,
		case when @RestaurantWeek is not null then @RestaurantWeek else 0 end,
		case when @Promotional is not null then @Promotional else 0 end,
		case when @Product is not null then @Product else 0 end,
		GETUTCDATE()
	);

SET @DBError = @@ERROR
IF @DBError <> 0
	GOTO general_error

COMMIT TRAN
RETURN(0)

general_error:
	ROLLBACK TRANSACTION
	EXEC procLogProcedureError 1, @ProcName, @Action, @DBError
	RETURN(0)
GO

GRANT EXECUTE ON [UserSvc_SetEmailPreferences] TO ExecuteOnlyRole
GO
