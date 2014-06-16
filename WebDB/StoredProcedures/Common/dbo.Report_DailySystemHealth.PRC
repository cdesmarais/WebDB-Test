if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_DailySystemHealth]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_DailySystemHealth]
GO

CREATE PROCEDURE dbo.Report_DailySystemHealth
(
  @dateoffset int = 1
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


Select 	(select count(ResID) from Reservation  where ShiftDate > (getdate()-5) and RStateID = 5) as UpdateCount
,(select count(CreditCardID) from Reservation where CreditCardID IS NOT NULL) as CCCount
,(select count(*) from LogFailedResos where datediff(d,FailTime,getdate()-@dateoffset) = 0) as ResoCount
,(select count(*) from Customer where PartnerID = 10 and Active = 1) + (select count(*) from Caller where PartnerID = 10) as AMEXPartnerIDs
,(select count(*) from Restaurant where MaxOnlineOptionID <> MaxLargePartyID and AcceptLargeParty = 0) as LargePartyProblem
,convert(nvarchar, dateadd(d,-@dateoffset,current_timestamp),101) as report_date

GO

GRANT EXECUTE ON [Report_DailySystemHealth] TO ExecuteOnlyRole

GO
