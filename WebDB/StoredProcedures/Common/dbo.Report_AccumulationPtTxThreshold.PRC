

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_AccumulationPtTxThreshold]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_AccumulationPtTxThreshold]
GO
  
create procedure dbo.Report_AccumulationPtTxThreshold  
(  
	@ThresholdPoints int  
	,@LookBackInMonths int   
)  
as  

set nocount on
set transaction isolation level read uncommitted
  
/* This is monthly report and pulls in all the employees that have awarded more than   
points greater than or equal to input param @ThresholdPoints over multiple accounts in a rolling 12  
month period (inclusive of the month the report is pulled for and going back 11 months)  
This report looks back for 12 months (which is configurable with help of @LookBackInMonths  
param )including current month.   

*/

declare @FromDate datetime  
declare @ToDate datetime  
declare @ComputeFromDate datetime
declare @ComputeToDate datetime
declare @CurrentDate datetime

  
/* if no look back is specified then default the value to 12*/  
if @LookBackInMonths =  0 or @LookBackInMonths > 12    
	set @LookBackInMonths =12  

/*Set the current date*/ 
set @CurrentDate = getdate()
 
/* Get the date range for the report  */  
set @FromDate = dateadd(ms, -3, dateadd (m,datediff(m,0,dateadd(m,1,dateadd(m,-(@LookBackInMonths), @CurrentDate))),0))  
set @ToDate =dateadd(ms, -3, dateadd (m,datediff(m,0,dateadd(m,1,@CurrentDate)),0))  

/* computation on FromDate and ToDate so that we can inherit ToDate date computation logic  */
set @ComputeFromDate = dateadd(m,-2,@ToDate) 
set @ComputeToDate = dateadd(m,-1,@ToDate)

/* Dont change the column alias and sequence as all the column appear as it is on the excel report  */  
  
select   
	PtAdjust.AdjusterCharmUserEmail as Employee   
	,PtAdjust.AdjustmentDate as [Date/Time]  
	,PtAdjust.AdjustmentAmount as [Points Amount]  
	,cust.CustId as CustomerId   
	,Coalesce(cust.FName,'')  + ' ' +  Coalesce(cust.LName,'') as [Customer Name]   
	,dbo.fGetCustomerType(0, -1,cust.ConsumerType) as [Customer Type]
	,case when lower(PtAdjReason.CHARMExplanation) = 'other'   
	then rtrim(ltrim(PtAdjust.AdjusterOtherReason)) else rtrim(ltrim(PtAdjReason.CHARMExplanation)) end  
	as [Point Adjustment Reason]      

from   
	pointsadjustment PtAdjust   
	
	inner join pointsadjustmentreason PtAdjReason on 
	PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID  
	
	inner join customer cust on 
	cust.CustId = PtAdjust.custid  

	inner join dbo.fGetTotalPointsByUserType(0,@FromDate,@ToDate) TotalPts on
	TotalPts.Id = PtAdjust.AdjusterCharmUserId  

where   
	PtAdjust.AdjustmentDate > @FromDate and 
	PtAdjust.AdjustmentDate <= @ToDate  and 
	TotalPts.TotalPoints >= @ThresholdPoints

union  
(  
	select   
		PtAdjust.AdjusterCharmUserEmail    
		,PtAdjust.AdjustmentDate   
		,PtAdjust.AdjustmentAmount   
		,caller.CallerId   
		,Coalesce(caller.FName,'')  + ' ' +  Coalesce(caller.LName,'') as [Customer Name]   
		,dbo.fGetCustomerType(1,caller.CompanyId,caller.ConsumerType) as [Customer Type]
		,case when lower(PtAdjReason.CHARMExplanation) = 'other'   
		then rtrim(ltrim(PtAdjust.AdjusterOtherReason)) else rtrim(ltrim(PtAdjReason.CHARMExplanation)) end     

	from   
		pointsadjustment PtAdjust   
		
		inner join pointsadjustmentreason PtAdjReason on 
		PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID  
		
		inner join caller  on 
		caller.CallerId = PtAdjust.CallerId   

		inner join dbo.fGetTotalPointsByUserType(0,@FromDate,@ToDate) TotalPts  on  
		TotalPts.Id = PtAdjust.AdjusterCharmUserId   

 where   
		PtAdjust.AdjustmentDate > @FromDate and 
		PtAdjust.AdjustmentDate <= @ToDate  and 
		TotalPts.TotalPoints >= @ThresholdPoints  
)  
  
order by 
	[Employee] asc 
	,[Points Amount] desc  
GO
   
GRANT EXECUTE ON [Report_AccumulationPtTxThreshold] TO ExecuteOnlyRole

GO


