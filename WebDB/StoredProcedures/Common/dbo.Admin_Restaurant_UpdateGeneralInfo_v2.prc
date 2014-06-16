
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateGeneralInfo_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateGeneralInfo_v2]
GO


CREATE PROCEDURE [dbo].[Admin_Restaurant_UpdateGeneralInfo_v2]
 (
	@RestaurantID int,
	@RName nvarchar(255),
	@RSName nvarchar(255),
	@NeighborhoodID int,
	@Description nvarchar(999),
	@Hours nvarchar(999),
	@Chef nvarchar(255),
	@Image nvarchar(256),
	@RestImage nvarchar(256),
	@StyleID int,
	@Entertainment nvarchar(999),
	@SmokingID int,
	@DressCodeID int,
	@PriceQuartileID int,
	@WalkinID int,
	@MinPartySize int,
	@MinCCPartySize int,
	@LargePartySize int,
	@HowFar int,
	@ConfirmationMessage nvarchar(999),
	@SpecialEvents nvarchar(999),
	@FoodTypes nvarchar(255),
	@Offers nvarchar(255),
	@PaymentOptions nvarchar(255),
 @IsActive int  ,
 @SpecialEventStartDate datetime,
 @SpecialEventEndDate datetime
)

AS

-- 
-- This v2 version initializes the new MinCCOnlineOption column (WR2009R4 TT 25524)
-- It continues to set the soon-to-be-depracated MaxOnlineOptionID
-- 

declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000)  
declare @DBError int 
declare @AcceptLargeParty bit
Declare @TimeZoneID int
declare @LanguageID int 
DECLARE @DomainID INT
set @ProcName = 'Admin_Restaurant_Update'  
set @Action = 'Proc Started'  

set @AcceptLargeParty = 0
if @MinCCPartySize <> @LargePartySize
 set @AcceptLargeParty = 1

Select @TimeZoneID = m.TZID 
from MetroArea m
inner join Neighborhood n on m.MetroAreaID = n.MetroAreaID
where n.NeighborhoodID = @NeighborhoodID

BEGIN TRANSACTION


--***************************  
--** Retrieve LanguageID  
--***************************  
set @Action = 'Retrieve LanguageID'  
exec @LanguageID = procGetDBUserLanguageID  
set @DBError = @@error  
if @DBError <> 0  
 goto error  
  
IF @RName <> (select R.Rname from RestaurantVW R where R.RID = @RestaurantID)
	OR @RSName <> (select R.RSname from RestaurantVW R where R.RID = @RestaurantID)
	Begin
		set @Action = 'Restaurant Name Changed'  
    
		Declare @ExpireDT datetime
		Set @ExpireDT = getdate()	
   
		Update	RestNameChange		--Expire/Version Old RNAME 
		SET		ExpireDT = @ExpireDT
		where	RID = @RestaurantID
			and  LanguageID = @LanguageID  
			and  ExpireDT > @ExpireDT   
	  
		set @DBError = @@error  
		if @DBError <> 0  
			goto error  
	  
		insert into RestNameChange --Insert new Rname with a new record  
		(RID, LanguageID, ResoRname, EffectiveDT)
		values (@RestaurantID, @LanguageID, @RName, @ExpireDT)
	    
		set @DBError = @@error  
		if @DBError <> 0  
			goto error  
	END

set @Action = 'update RestaurantLocal'

Select @DomainID = DomainID from Restaurant where RID = @RestaurantID

BEGIN

	UPDATE 	[RestaurantLocal]
	SET	[RName] = @RName,
		[RSName] = @RSName
	WHERE 	[RID] = @RestaurantID
	AND	[LanguageID] = @LanguageID

END

UPDATE [RestaurantLocal]
	SET	[Chef] = @Chef,
		[IsActive] = @IsActive
	WHERE	[RID] = @RestaurantID
	AND	[LanguageID] = @LanguageID
set @DBError = @@error  
if @DBError <> 0  
 goto error  

set @Action = 'update Restaurant' 
UPDATE [Restaurant]
	SET	[SmokingID] = @SmokingID,
		[DressCodeID] = @DressCodeID,
		[PriceQuartileID] = @PriceQuartileID,
		[WOID] = @WalkinID,
		[TZID] = @TimeZoneID,
		[NeighborhoodID] = @NeighborhoodID,
		[MinOnlineOptionID] = @MinPartySize,
		[MinCCOptionID] = @MinCCPartySize,
		[MaxLargePartyID] = @LargePartySize,
		[AcceptLargeParty] = @AcceptLargeParty,
		[MaxAdvanceOptionID] = @HowFar,
		[DiningStyleID] = @StyleID,
		[MaxOnlineOptionID] =
			CASE			-- maintain the MaxOnlineOptionID properly.  Normally MinCC-1, but handle endpoints specifically
				WHEN @MinCCPartySize = 20 THEN 20 
				WHEN @MinCCPartySize = 1 THEN 1
				ELSE @MinCCPartySize - 1 
			END

	WHERE	[RID] = @RestaurantID
set @DBError = @@error  
if @DBError <> 0  
 goto error  


set @Action = 'Update Restaurant Description Message'  
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'RestaurantDescription',@Description
set @DBError = @@error  
if @DBError <> 0  
 goto error  

set @Action = 'Update Hours Message'  
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'Hours',@Hours
set @DBError = @@error  
if @DBError <> 0  
 goto error  

set @Action = 'Update Entertainment Message'  
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'Entertainment',@Entertainment
set @DBError = @@error  
if @DBError <> 0  
 goto error  

set @Action = 'Update Confirmation Message'
exec DNRestaurantSetCustomMessageFromName @RestaurantID,'Confirmation',@ConfirmationMessage
set @DBError = @@error  
if @DBError <> 0  
 goto error  

set @Action = 'Update Special Events message'
exec DNRestaurantSetCustomMessageWithDatesFromName @RestaurantID,'SpecialEvents',@SpecialEvents, @SpecialEventStartDate, @SpecialEventEndDate
set @DBError = @@error  
if @DBError <> 0  
 goto error  

set @Action = 'Update restaurant Images'
exec dbo.Admin_Restaurant_UpdateImages @RestaurantID, @Image, @RestImage
set @DBError = @@error  
if @DBError <> 0  
 goto error  

set @Action = 'Update FoodTypes'
EXEC dbo.Admin_FoodTypes_Delete @RestaurantID = @RestaurantID
EXEC dbo.Admin_FoodTypes_Add @RestaurantID = @RestaurantID, @FoodTypeID =  @FoodTypes
set @DBError = @@error  
if @DBError <> 0  
 goto error  
  
set @Action = 'Update Offers'
Exec dbo.Admin_Offers_Delete @RestaurantID = @RestaurantID
Exec dbo.Admin_Offers_Add @RestaurantID=@RestaurantID, @OfferID=@Offers
set @DBError = @@error
if @DBError <> 0
  goto error
  
set @Action = 'Update Payments'
Exec dbo.Admin_PaymentTypes_Delete @RestaurantID = @RestaurantID
Exec dbo.Admin_PaymentTypes_Add @RestaurantID=@RestaurantID, @PaymentTypeID=@PaymentOptions
set @DBError = @@error
if @DBError <> 0  
  goto error 
COMMIT TRANSACTION  
Return(0)  
  
error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1)  
  
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateGeneralInfo_v2] TO ExecuteOnlyRole

GO