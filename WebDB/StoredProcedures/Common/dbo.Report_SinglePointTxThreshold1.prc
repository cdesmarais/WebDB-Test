


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_SinglePointTxThreshold1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_SinglePointTxThreshold1]
GO
  
create procedure dbo.Report_SinglePointTxThreshold1  
(  
	@ThresholdPoints int
)  
as  
  
/* This report pulls all such transaction which awarded points greater  
than or equal to input param @ThresholdPoints in single transaction for a single account.  

Transaction which fall only in prior month period will be included in this report.  
*/  

declare @FromDate datetime  
declare @ToDate datetime  
declare @CurrentDate datetime
  
/*Set the current date */
set @CurrentDate = getdate()  

/* Get the date range of the prior month for the report  */  
set @FromDate = dateadd(mm,-1,dateadd(mm,datediff(mm,0,@CurrentDate),0))  
set @ToDate = dateadd(s,-1,dateadd(mm, datediff(m,0,@CurrentDate),0))  
  
/* Dont change the column alias and sequence as all the column appear as it is on the   
excel report  
 */  
select   
	PtAdjust.AdjusterCharmUserEmail as Employee   
	,PtAdjust.AdjustmentDate as [Date/Time]  
	,PtAdjust.AdjustmentAmount as [Points Amount]  
	,cust.CustId as CustomerId   
	,coalesce(cust.FName,'')  + ' ' +  coalesce(cust.LName,'') as [Customer Name]   
	,dbo.fGetCustomerType(0, -1,cust.ConsumerType) as [Customer Type]
	,case 
		when lower(PtAdjReason.CHARMExplanation) = 'other'   
		then PtAdjust.AdjusterOtherReason 
	 else PtAdjReason.CHARMExplanation end  as [Point Adjustment Reason]   

from   
	pointsadjustment PtAdjust   
	
	inner join pointsadjustmentreason PtAdjReason on 
	PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID  
	
	inner join customer cust on 
	cust.CustId = PtAdjust.custid   

where  
	/* Below where clause is included as only new entries are to be shown on reports*/  
	PtAdjust.AdjusterCharmUserId is not null and 
	PtAdjust.SysUser is not null   
	/* this is done because both records with negative pointsadjustment amount less than   
	@ThresholdPoints and positive pointsadjustment amount greater than @ThresholdPoints  
	should be included in the resultset*/   
	and (
			case 
				when PtAdjust.AdjustmentAmount < 0 
				then -PtAdjust.AdjustmentAmount  
			else PtAdjust.AdjustmentAmount end
		)  >= @ThresholdPoints  and 
	PtAdjust.AdjustmentDate > @FromDate  and 
	PtAdjust.AdjustmentDate <= @ToDate   
union  
(  
	select   
		PtAdjust.AdjusterCharmUserEmail   
		,PtAdjust.AdjustmentDate   
		,PtAdjust.AdjustmentAmount   
		,caller.CallerId   
		,coalesce(caller.FName,'')  + ' ' +  coalesce(caller.LName ,'')  
		,dbo.fGetCustomerType(1,caller.CompanyId,caller.ConsumerType) as [Customer Type]	
		,case 
			when lower(PtAdjReason.CHARMExplanation) = 'other'   
			then PtAdjust.AdjusterOtherReason 
		 else PtAdjReason.CHARMExplanation 
		 end     

	from   
 		pointsadjustment PtAdjust   
		
		inner join pointsadjustmentreason PtAdjReason  on 
		PtAdjust.AdjReasonID = PtAdjReason.AdjReasonID  
		
		inner join caller on 
		caller.CallerId = PtAdjust.CallerId   
	 
	where  
		/* Below where clause is included as only new entries are to be shown on reports*/  
		PtAdjust.AdjusterCharmUserId is not null and 
		PtAdjust.SysUser is not null   
		/* this is done because both records with negative pointsadjustment amount less than   
		@ThresholdPoints and positive pointsadjustment amount greater than @ThresholdPoints  
		should be included in the resultset*/   
		and (
				case 
					when PtAdjust.AdjustmentAmount < 0 
					then -PtAdjust.AdjustmentAmount  
				else PtAdjust.AdjustmentAmount 
				end
			)  >= @ThresholdPoints  and 
		PtAdjust.AdjustmentDate > @FromDate  and 
		PtAdjust.AdjustmentDate <= @ToDate  
)  
  
order by 
		[Points Amount] desc
		,[Date/Time] asc  
GO

GRANT EXECUTE ON [Report_SinglePointTxThreshold1] TO ExecuteOnlyRole

GO


