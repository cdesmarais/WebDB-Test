
 if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportPOPTransaction]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
 drop procedure [dbo].[JobReportPOPTransaction]
 GO

  
 create procedure dbo.JobReportPOPTransaction  
   
 As  
  
 set nocount on  
 set transaction isolation level read uncommitted  
  
 /* This Stored procedure is used to detail each POP approval made for a restaurant within a prior month.  
 Time period is inclusive i.e it extracts data between first day to last day(both are inclusive.)  
 POP Approval Detail includes following columns  
 1. Approval Date  -: Date of Transaction when POP slots getting changes  
 2. Commissionable -: True  -> If POP Change is Commissionable  
          False -> If POP Change is uncommissionable  
 3. RID  
 4. Account Name   -: Restaurant Name  
 5. Lunch Prime Time Slots -: POP Slots between 11AM TO 1PM (both are inclusive)  
 6. Dinner Prime Time Slots -: POP Slots between 5PM TO 10PM (both are inclusive)  
 7. Total Slots  -: Total POP Slots count i.e Lunch Prime Time + Dinner Prime Time + Non-Prime Time  
   
 */   
   
	 declare @rptstartDate as DateTime    
	 declare @rptendDate as DateTime    
	    
	 --set report start and end dates    
	 set @rptstartDate = dateadd(mm,(datediff(m,0,getdate())-1),0)    
	 set @rptendDate = dateadd(s,-1,dateadd(mm,(datediff(m,0,getdate())),0))    
	 
	 
	 
	SELECT 
		--Show date in mm/dd/yyy hh:mm AM/PM format
		convert(varchar(10), Currentvalues.CreateDate, 101) + ' ' + ltrim((right(convert(VARCHAR, Currentvalues.CreateDate, 100), 7))) as [Approval Date]
		,case     
			when Currentvalues.IsCommissionable = 1 then 'TRUE'    
			else 'FALSE'     
			end as [Commissionable]    
		,r.RID  as [RID]
		,r.RName as [Account Name]    
		,substring(Currentvalues.ContractSoldBy,0,charindex('[',Currentvalues.ContractSoldBy)) as [Rep 1 Name]
		,Currentvalues.ContractSoldByID as [Rep 1 ID]
		,substring(Currentvalues.SecondarySalesRep,0,charindex('[',Currentvalues.SecondarySalesRep)) as [Rep 2 Name]
		,Currentvalues.SecondarySalesRepID as [Rep 2 ID]
		,isnull(Currentvalues.CurrentLunchPrimeTimeSlots,0) as [Lunch Prime Time Slots]
		,isnull(Currentvalues.CurrentDinnerPrimeTimeSlots,0) as [Dinner Prime Time Slots]
		,isnull(Currentvalues.CurrentTotalSlots - ( Currentvalues.CurrentLunchPrimeTimeSlots + Currentvalues.CurrentDinnerPrimeTimeSlots ),0) as [Non Prime Time Slots] 
		,isnull((Currentvalues.CurrentLunchPrimeTimeSlots + Currentvalues.CurrentDinnerPrimeTimeSlots ),0) as [Total Prime Time Slots]
		,isnull(Currentvalues.CurrentTotalSlots,0) as [Total Slots]
		,isnull(priorvalues.CurrentDinnerPrimeTimeSlots,0) as [Prior Dinner Prime Time Slots]
		,isnull((priorvalues.CurrentDinnerPrimeTimeSlots +priorvalues.CurrentLunchPrimeTimeSlots),0) as [Prior Total Prime Time Slots]
		,isnull(Currentvalues.OTCovers,0) as [OT Covers (12 mo)]
		,isnull(Currentvalues.POPCovers,0) as [POP Covers (12 mo)]
		,case     
			when Currentvalues.CurrentSDPOPStatus = 1 then 'TRUE'    
			else 'FALSE'     
		 end as [SD POP Status]
		,case     
			when priorvalues.CurrentSDPOPStatus = 1 then 'TRUE'    
			else 'FALSE'     
		 end as [Prior SD POP Status]
		,convert(varchar(10),Currentvalues.SDPOPEnableDate,101) as [SD POP Enabled Date]
		,convert(varchar(10),Currentvalues.SDPOPDisableDate,101) as [SD POP Disabled Date]
	from 
		Restaurantvw r
		left join
		(
			SELECT 
				 IncHist.RID
				,CurrentDinnerPrimeTimeSlots
				,CurrentLunchPrimeTimeSlots
				,CurrentTotalSlots
				,CurrentSDPOPStatus
				,CreateDate
				,SDPOPEnableDate
				,SDPOPDisableDate
				,IsCommissionable
				,ContractSoldBy
				,ContractSoldByID
				,SecondarySalesRep
				,SecondarySalesRepID
				,OTCovers
				,POPCovers			
				,row_number() over ( partition by  IncHist.rid order by IncHistID) as rownum 
			from 
				dbo.IncentiveHistory IncHist
			left join 
				dbo.IncentiveSuppressDay IncSuppressDay
			on
				(IncHist.RID = IncSuppressDay.RID and (IncHist.IncHistID = IncSuppressDay.ActiveIncHistID
				or IncHist.IncHistID = IncSuppressDay.DeActiveIncHistID))
			where
				(IncSuppressDay.ActiveIncHistID is null and IncSuppressDay.DeActiveIncHistID is null)
		) Currentvalues
		on currentvalues.rid = r.rid 
		left join
		(
			SELECT	
				 IncHIst.RID
				,CurrentDinnerPrimeTimeSlots
				,CurrentLunchPrimeTimeSlots
				,CurrentTotalSlots
				,CurrentSDPOPStatus
				,row_number() over (partition by IncHist.rid order by IncHistID) as rownum 
			from 
				dbo.IncentiveHistory IncHIst			
			left join 
				dbo.IncentiveSuppressDay IncSuppressDay
			on
				(IncHist.RID = IncSuppressDay.RID and (IncHist.IncHistID = IncSuppressDay.ActiveIncHistID
				or IncHist.IncHistID = IncSuppressDay.DeActiveIncHistID))
			where
				(IncSuppressDay.ActiveIncHistID is null and IncSuppressDay.DeActiveIncHistID is null)
		) priorvalues
		on priorvalues.rid = r.rid and priorvalues.rownum = Currentvalues.rownum-1
	where
		currentvalues.CreateDate between @rptstartDate and @rptendDate
	order by
		 currentvalues.RID
		,currentvalues.CreateDate
 GO

 grant execute on [JobReportPOPTransaction] to ExecuteOnlyRole
 grant execute on [JobReportPOPTransaction] to DTR_User
 GO
 
