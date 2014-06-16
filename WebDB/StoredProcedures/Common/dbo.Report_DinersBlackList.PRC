

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_DinersBlackList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_DinersBlackList]
GO

create procedure dbo.Report_DinersBlackList  
(  
	@ThresholdPoints int
	,@LookBackInMonths int   
)  
as  
  
/* This is monthly report and pulls all diners that have received  
point greater than or equal to input param @ThresholdPoints over multiple transaction   
in a rolling 12 month period (inclusive of the month the report is pulled for and  
going back 11 months).  
  
This report looks back for 12 months (which is configurable with help of @LookBackInMonths  
param )including current month.   

User should only be repeated in the list if they have new activity in the gone by month.
*/

declare @FromDate datetime  
declare @ToDate datetime  
declare @ActivityFromDate datetime
declare @ActivityToDate datetime
declare @ComputeFromDate datetime
declare @ComputeToDate datetime
declare @CurrentDate datetime

/* if no look back is specified then default the value to 12*/  
if @LookBackInMonths =  0 or @LookBackInMonths > 12    
	set @LookBackInMonths = 12  

/*Set the current date*/ 
set @CurrentDate = getdate()

/* Get the date range for the report  */  
set @FromDate = dateadd(ms, -3, dateadd (m,datediff(m,0,dateadd(m,1,dateadd(m,-(@LookBackInMonths), @CurrentDate))),0))  
set @ToDate = dateadd(ms, -3, dateadd (m,datediff(m,0,dateadd(m,1,@CurrentDate)),0))  

/* computation on FromDate and ToDate so that we can inherit ToDate date computation logic  */
set @ComputeFromDate = dateadd(m,-2,@ToDate) 
set @ComputeToDate = dateadd(m,-1,@ToDate)

/* Get TO and FROM date of gone by month */
set @ActivityFromDate = dateadd(ms,-1,dateadd(mm, datediff(m,0,@ComputeFromDate)+1,0))
set @ActivityToDate = dateadd(s,-1,dateadd(mm, datediff(m,0,@ComputeToDate)+1,0))
  
/* Dont change the column alias and sequence as all the column appear as it is on the excel report  */  
select   
	cust.CustId as CustomerId   
	,coalesce(cust.FName,'')  + ' ' +  coalesce(cust.LName,'') as [Customer Name]  
	,dbo.fGetCustomerType(0, -1,cust.ConsumerType) as [Customer Type]
	,PtAdjust.AdjustmentDate as [Date/Time]  
	,PtAdjust.AdjustmentAmount as [Points Amount]   
	,case 
		when lower(PtAdjReason.CHARMExplanation) = 'other'   
		then PtAdjust.AdjusterOtherReason 
	 else PtAdjReason.CHARMExplanation 
	 end  as [Point Adjustment Reason]   
	,PtAdjust.AdjusterCharmUserEmail as Employee     
 
from   
	pointsadjustment PtAdjust   
	
	inner join pointsadjustmentreason PtAdjReason on 
	PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID  
	
	inner join customer cust on
	cust.CustId = PtAdjust.custid  
	
	inner join dbo.fGetTotalPointsByUserType(1,@FromDate,@ToDate) TotalPts  on  
	TotalPts.Id = PtAdjust.CustId

where   
	PtAdjust.AdjustmentDate > @FromDate  and 
	PtAdjust.AdjustmentDate <= @ToDate   and 
	TotalPts.TotalPoints >= @ThresholdPoints and 
		(
			select 
				count(*) 
			from 
				pointsadjustment 
			where 
				pointsadjustment.CustId = cust.CustId and 
				AdjustmentDate between @ActivityFromDate and @ActivityToDate
		) > 0
union  
(  
	select   
		caller.CallerId   
		,coalesce(caller.FName,'')  + ' ' +  coalesce(caller.LName,'')  
		,dbo.fGetCustomerType(1,caller.CompanyId,caller.ConsumerType) as [Customer Type]
		,PtAdjust.AdjustmentDate   
		,PtAdjust.AdjustmentAmount   
		,case 
			when lower(PtAdjReason.CHARMExplanation) = 'other'   
			then PtAdjust.AdjusterOtherReason 
		 else PtAdjReason.CHARMExplanation 
		 end       
		,PtAdjust.AdjusterCharmUserEmail     

	from   
		pointsadjustment PtAdjust   
		
		inner join pointsadjustmentreason PtAdjReason on 
		PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID  
		
		inner join caller on 
		caller.CallerId = PtAdjust.CallerId   
		
		inner join dbo.fGetTotalPointsByUserType(2,@FromDate,@ToDate) TotalPts on  
		TotalPts.Id = PtAdjust.CallerId   
		
	where   
		PtAdjust.AdjustmentDate > @FromDate  and 
		PtAdjust.AdjustmentDate <= @ToDate  and 
		TotalPts.TotalPoints >= @ThresholdPoints  and 
			(
				select 
					count(*) 
				from 
					pointsadjustment 
				where 
					pointsadjustment.CallerId = caller.CallerId and 
					AdjustmentDate between @ActivityFromDate and @ActivityToDate
			) > 0
)  
  
order by 
		[Customer Name] asc
		,[Points Amount] desc   
GO  

GRANT EXECUTE ON [Report_DinersBlackList] TO ExecuteOnlyRole

GO


