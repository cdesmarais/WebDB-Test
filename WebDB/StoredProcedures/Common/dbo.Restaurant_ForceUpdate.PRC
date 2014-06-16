if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ForceUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ForceUpdate]
GO




CREATE Procedure dbo.Restaurant_ForceUpdate
/*this stored proc will update restaurant's LTC to one day in the future for all restaurants whose LTC is within the past 24 hours*/

 AS
/*revised 1/27/03 to remove use of 'last time contacted' field for performance/recompilation reasons...
*/
SET NOCOUNT ON
set transaction isolation level read uncommitted

/*update non-allotment restaurants*/
Declare @DateNow as datetime, @UTCNow as datetime -- Add UTCNow to track LTC_UTC field

Select @DateNow = GetDate(), @UTCNow = GetUTCDate()

update LastTimeContacted set LTC = (@DateNow  + 1),
							 LTC_UTC =(@UTCNow  + 1) where
LTC > (getDate() - 1) and RID not in
(select RID from Restaurant where RestStateID <> 1 or Allotment = 1)

/*set allotment restaurants LTC equal to the default allotment LTC date*/

update LastTimeContacted set LTC = '1-1-2014',
							LTC_UTC ='1-1-2014' where
RID in (select RID from Restaurant where Allotment = 1 and RestStateID = 1)
GO

GRANT EXECUTE ON [Restaurant_ForceUpdate] TO ExecuteOnlyRole

GO
