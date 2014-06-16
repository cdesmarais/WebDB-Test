if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationGetPointsForTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationGetPointsForTime]
GO



CREATE PROCEDURE dbo.DNReservationGetPointsForTime 
(
@RestID int,
@ResDateTime datetime,
@PartySize int = 0,/*added JD - 11-7-2003 - for future use with incentives which calculate by cover*/
@points nvarchar(255) OUTPUT
)
AS
SET NOCOUNT ON
/*revised 11/7/03
created 10/6/2003*/
declare @temp int

 declare @unusedOut int 
 exec procIncentiveLookup @RestID, @ResDateTime, @unusedOut output, @temp output
 
 if @temp is not null
  set @points = Cast( @temp as nvarchar(254))
else
  set @points = '100' -- min point value for a reso ... until business rule changes
GO

GRANT EXECUTE ON [DNReservationGetPointsForTime] TO ExecuteOnlyRole

GO
