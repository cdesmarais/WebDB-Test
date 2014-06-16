


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_SinglePointTxThreshold]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_SinglePointTxThreshold]
GO


set ansi_nulls on
go
set quoted_identifier on
go


CREATE PROCEDURE dbo.Report_SinglePointTxThreshold
(
	@ThresholdPoints int,
	@LookBackInDays int	
)
AS

SET NOCOUNT ON

/* This report pulls all such transaction which awarded points greater
than or equal to input param @ThresholdPoints in single transaction for a single account.
Transaction which fall in look back period will be included in this report.
*/

declare @FromDate datetime
declare @ToDate datetime

if @LookBackInDays = 0  
	set @LookBackInDays =7

/* Get the date range for the report  */
set @FromDate = dateadd(ms, -3, dateadd (d,datediff(d,0,dateadd(d,-(@LookBackInDays), getdate())),0))
set @ToDate =dateadd(ms, -3, dateadd (d,datediff(d,0,getdate()),0))

print @FromDate
print @ToDate
/* Dont change the column alias and sequence as all the column appear as it is on the 
excel report
 */
	select 
		PtAdjust.AdjusterCharmUserEmail as Employee 
		,PtAdjust.AdjustmentDate as [Date/Time]
		,PtAdjust.AdjustmentAmount as [Points Amount]
		,cust.CustId as CustomerId 
		,Coalesce(cust.FName,'')  + ' ' +  Coalesce(cust.LName,'') as [Customer Name] 
		,case when lower(PtAdjReason.CHARMExplanation) = 'other' 
		 then PtAdjust.AdjusterOtherReason else PtAdjReason.CHARMExplanation end
		 as [Point Adjustment Reason]	
	from 
	pointsadjustment PtAdjust 
	inner join pointsadjustmentreason PtAdjReason
	on PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID
	inner join customer cust
	on cust.CustId = PtAdjust.custid	
	where
	/* Below where clause is included as only new entries are to be shown on reports*/
	PtAdjust.AdjusterCharmUserId is not null 
	and PtAdjust.SysUser is not null	
	/* this is done because both records with negative pointsadjustment amount less than 
	@ThresholdPoints and positive pointsadjustment amount greater than @ThresholdPoints
	should be included in the resultset*/	
	and (case when PtAdjust.AdjustmentAmount < 0 then -PtAdjust.AdjustmentAmount
	else PtAdjust.AdjustmentAmount end)  >= @ThresholdPoints
	and	PtAdjust.AdjustmentDate > @FromDate
	and PtAdjust.AdjustmentDate <= @ToDate	


union
(
	select 
		PtAdjust.AdjusterCharmUserEmail 
		,PtAdjust.AdjustmentDate 
		,PtAdjust.AdjustmentAmount 
		,caller.CallerId 
		,Coalesce(caller.FName,'')  + ' ' +  Coalesce(caller.LName ,'')
		,case when lower(PtAdjReason.CHARMExplanation) = 'other' 
		 then PtAdjust.AdjusterOtherReason else PtAdjReason.CHARMExplanation end			
	from 
	pointsadjustment PtAdjust 
	inner join pointsadjustmentreason PtAdjReason
	on PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID
	inner join caller 
	on caller.CallerId = PtAdjust.CallerId	
	where
	/* Below where clause is included as only new entries are to be shown on reports*/
	PtAdjust.AdjusterCharmUserId is not null 
	and PtAdjust.SysUser is not null	
	/* this is done because both records with negative pointsadjustment amount less than 
	@ThresholdPoints and positive pointsadjustment amount greater than @ThresholdPoints
	should be included in the resultset*/	
	and (case when PtAdjust.AdjustmentAmount < 0 then -PtAdjust.AdjustmentAmount
	else PtAdjust.AdjustmentAmount end)  >= @ThresholdPoints 
	and	PtAdjust.AdjustmentDate > @FromDate
	and PtAdjust.AdjustmentDate <= @ToDate
)

order by [Points Amount] desc,[Date/Time] asc
GO

GRANT EXECUTE ON [Report_SinglePointTxThreshold] TO ExecuteOnlyRole

GO


