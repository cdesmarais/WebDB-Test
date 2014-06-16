--OTCreateUpdateAlert <rid>,<notes>,<alerttype>
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTCreateUpdateAlert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTCreateUpdateAlert]
GO


-- Create an alert if doesnt exist, else just increment the hit count on the alert
CREATE PROCEDURE dbo.OTCreateUpdateAlert
(
	@RID int,
	@Notes nvarchar(500),
	@AlertType int
)
AS

SET NOCOUNT ON;

declare @TierID int

-- check if alert exists..
if not exists (select * from otalerts where alerttypeid=@AlertType and RID=@RID and Status=1)
    BEGIN
	-- get tier for new alert based on alert type..
	select @TierID=alerttierid from otalerttiers where tier = (select min(tier) from otalerttiers where alerttypeid=@AlertType) and alerttypeid=@AlertType

	-- alert must be created
	insert into otalerts(RID,AlertTypeID,Notes,Status,AlertCreateDateTS,NotificationSentCount,TierID,HasOwner)
	values(@RID,@AlertType,@Notes,1,getdate(),0,@TierID,0)
	
	-- return AlertID to caller
	SELECT scope_identity() as AlertID,@TierID as TierID
    END

GO
GRANT EXECUTE ON [OTCreateUpdateAlert] TO ExecuteOnlyRole

GO
