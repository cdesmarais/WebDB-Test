
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_DFF_Response_Rate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_DFF_Response_Rate]
GO

CREATE PROCEDURE dbo.Report_DFF_Response_Rate
(
	 @startdt	datetime = null -- Optional parameter, if not set then the default date in the valuelookup table will be used
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @LookBackDays int

select		@LookBackDays = vl.ValueInt
from		ValueLookup vl
where		LKey = 'DffRspRateRptLookbackDays'

select 		year(createdt) as Year, month(createdt) as Month, day(createdt) as Day, count(*) as 'DFF Emails Sent'
from 		dbo.DFBEmailSentLog 
where 		createdt > ISNULL(@startdt,dateadd(d,-@LookBackDays,getdate()))
group by 	year(createdt), month(createdt), day(createdt)
order by 	year(createdt), month(createdt), day(createdt)

GO


GRANT EXECUTE ON [Report_DFF_Response_Rate] TO ExecuteOnlyRole

GO
