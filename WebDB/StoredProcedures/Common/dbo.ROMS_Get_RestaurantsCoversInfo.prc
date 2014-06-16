if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_Get_RestaurantsCoversInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ROMS_Get_RestaurantsCoversInfo]
go
set ansi_nulls on
go
set quoted_identifier on
go
--this is used to get restaurant covers information from otreport db.
--romsidlist  is the optinal parameter, it romsidlist is not null then it should be comma delimited list of restauratids  
create procedure [dbo].[ROMS_Get_RestaurantsCoversInfo]  
(
	@Month  int ,  
	@Year  int ,  
	@ROMSIDList varchar(8000)=null  
)
as  
	-- figure out which batch the date belong to..
	declare @theBID int
	declare @theBatchReportDT datetime
	
	select 
		@theBID=max(BID),
		@theBatchReportDT = reportdt
		from 
			otrpbatch
		where
			Month(ReportDt) = @Month
			and Year(ReportDt) =  @Year
			and BatchStatusID = 1
		group by 
			reportdt


	select    
		 summVw.ROMSID as RestaurantID,
		 TotalOTCovers as OTCovers,
		 TotalRestCovers as RestRefCovers,
		 TotalDIPCovers as DIPCovers,
		 0 as ConciergeCovers,
		 @Month as CoversMonth,
		 @Year as CoversYear,
		 summVw.rid as WebRID  
  
   
	from	OTRPMonthlyAcctSummaryVW summVw    

	where	
		summVw.ROMSID IS NOT NULL   
		and ReportDt=@theBatchReportDT
		and (@ROMSIDList IS NULL OR CHARINDEX(',' + CAST( summVw.ROMSID AS nvarchar) + ',', ',' + @ROMSIDList + ',')>0 )
		
 

	--get the Concierge covers data from OTRPFinanceExtractBillableVW by passing month and year..   

	select 
		ROMSID as RestaurantID,
		count (ROMSID)as ConciergeCovers
	
	from		OTRPFinanceExtractBillableVW  
	
	where		
		resoType = 'Concierge'  
		and BID=@theBID
		and ROMSID is not null  
		and (@ROMSIDList IS NULL OR CHARINDEX(',' + CAST( ROMSID AS nvarchar) + ',', ',' + @ROMSIDList + ',')>0 )
	
	group by	
		ROMSID  
  
  
go
grant execute on [ROMS_Get_RestaurantsCoversInfo] TO ExecuteOnlyRole
go

