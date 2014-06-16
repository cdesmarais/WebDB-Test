if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_getPointsForTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_getPointsForTime]
GO



CREATE Procedure dbo.Reservation_getPointsForTime 
(
@RestID int,
@ResDateTime datetime,
@PartySize int,
@points nvarchar(255) OUTPUT
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @temp int

select @temp = amount from  Incentive where active = 1 and RID = @RestID
 	and IncentiveDay = datepart(dw,@ResDateTime) 
	and StartTime <= cast(convert(nvarchar,@ResDateTime,108) as datetime) 
 	and EndTime > cast(convert(nvarchar,@ResDateTime,108) as datetime)
  	and Startdate <= cast(convert(nvarchar,@ResDateTime,110) as datetime)
 	and Enddate >= cast(convert(nvarchar,@ResDateTime,110) as datetime)
 
 if @temp is not null
  set @points = 'i' + Cast( (@temp * @PartySize) as nvarchar(254))
else
  set @points = '100' -- min point value for a reso ... until business rule changes
GO

GRANT EXECUTE ON [Reservation_getPointsForTime] TO ExecuteOnlyRole

GO
