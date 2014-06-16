IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Report_MarketingPOP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Report_MarketingPOP]
GO

CREATE PROCEDURE Report_MarketingPOP AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	DECLARE @POPInventory TABLE 
	(RID INT,
	RestaurantName NVARCHAR (100),
	MetroAreaName NVARCHAR (100),
	ContractSoldBy NVARCHAR (100), 
	[Monday 11AM - 1PM] INT,  
	[Tuesday 11AM - 1PM] INT, 
	[Wednesday 11AM - 1PM] INT, 
	[Thursday 11AM - 1PM] INT, 
	[Friday 11AM - 1PM] INT,
	[Saturday 11AM - 1PM] INT,
	[Sunday 11AM - 1PM] INT,
	[Monday 5PM - 10PM] INT,  
	[Tuesday 5PM - 10PM] INT, 
	[Wednesday 5PM - 10PM] INT, 
	[Thursday 5PM - 10PM] INT, 
	[Friday 5PM - 10PM] INT,
	[Saturday 5PM - 10PM] INT,
	[Sunday 5PM - 10PM] INT,
	[Total 11AM - 1PM] INT,
	[Total 5PM - 10PM] INT,
	[Total] INT)

	INSERT @POPInventory (RID, RestaurantName, MetroAreaName, ContractSoldBy, [Monday 11AM - 1PM],  [Tuesday 11AM - 1PM], [Wednesday 11AM - 1PM], [Thursday 11AM - 1PM],
	[Friday 11AM - 1PM], [Saturday 11AM - 1PM], [Sunday 11AM - 1PM], [Monday 5PM - 10PM],  [Tuesday 5PM - 10PM], [Wednesday 5PM - 10PM], [Thursday 5PM - 10PM],
	[Friday 5PM - 10PM], [Saturday 5PM - 10PM], [Sunday 5PM - 10PM], [Total 11AM - 1PM], [Total 5PM - 10PM], [Total])
	EXEC ExtractDIPInventory

	declare @currentdate date						
	declare @pastmonthstartdate date						
	declare @pastmonthenddate date						
	declare @lastweekstartdate date						
	declare @lastweekenddate date						
	declare @thisweekstartdate date						
	declare @thisweekenddate date						
							
	Set @currentdate=dateadd(d,-7,GETDATE())					
	set @pastmonthstartdate=(DATEADD(dd,(-1) * (DATEPART(dd,@currentdate) - 1) ,DATEADD(mm,-1,@currentdate)))						
	set @pastmonthenddate = (DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@currentdate),0)))						
	set @lastweekstartdate = (dateadd(d,2-datepart(dw,@currentdate),@currentdate))						
	set @lastweekenddate = (DATEADD(D,6,@lastweekstartdate))						
	SET @thisweekstartdate = DATEADD(wk,1,@lastweekstartdate)						
	SET @thisweekenddate = DATEADD(wk,1,@lastweekenddate)						
							
	SELECT DISTINCT	
				r.rid, 					
				r.RName, 			
				n.MetroAreaID,			
				m.MetroAreaName,			
				n.NbhoodName,			
				ft.FoodType,			
				isnull(reso.Covers,0) AS Covers,			
				isnull(Dipreso.DipCovers,0) As POPCovers,		
				rev.AverageOverallRating as [Star Rating],			
				rev.TotalDffs as [Active Reviews],			
				case when len(isnull(imagename, '')) > 0 then 1 else 0 end AS HasProfilePhoto,
				[Monday 5PM - 10PM] AS Monday,  
				[Tuesday 5PM - 10PM] AS Tuesday, 
				[Wednesday 5PM - 10PM] AS Wednesday, 
				[Thursday 5PM - 10PM] AS Thursday, 
				[Friday 5PM - 10PM] AS Friday, 
				[Saturday 5PM - 10PM] AS Saturday, 
				[Sunday 5PM - 10PM] AS Sunday,
				NewestStartDate,
				OldestStartDate							
	FROM		dbo.RestaurantVW r
	inner join 	@POPInventory d
	on d.RID = r.RID			
	inner join	dbo.NeighborhoodVW n 					
	on			n.NeighborhoodID=r.NeighborhoodID			
	inner join	dbo.MetroAreaVW m					
	on			m.MetroAreaID=n.MetroAreaID					
	left join   (select rid, foodtypeid FROM (SELECT rid, foodtypeid, row_number() over (partition by rid order by ftrank) ranking from dbo.FoodTypes where IsPrimary=1) a						
				where ranking = 1) fts 			
	on			fts.RID = r.RID 			
	left join	dbo.foodtype ft					
	on			ft.FoodTypeID=fts.FoodTypeID and isnull(ft.LanguageID,0)=1			
	LEFT JOIN	(select rid, sum(ISNULL(SeatedSize, PartySize)) as Covers					
				from dbo.reservation			
				where RStateID in (1,2,5,7) and ShiftDate between @pastmonthstartdate and @pastmonthenddate			
				group by rid) reso			
	on			reso.RID = r.rid			
	LEFT JOIN	(select rid, sum(ISNULL(SeatedSize, PartySize)) as DIPCovers					
				from dbo.reservationvw			
				where RStateID in (1,2,5,7) and ShiftDate between @pastmonthstartdate and @pastmonthenddate
				and BillingType = 'DIPReso'			
				group by rid) Dipreso			
	on			dipreso.RID = r.rid	
	LEFT JOIN	(select webrid, totaldffs, averageoverallrating from dbo.DFFDailySummaryRIDStatsHolding) rev					
	ON			rev.webrid = r.RID			
	LEFT JOIN	dbo.RestaurantImage ri					
	ON			ri.RID=r.rid			
	left join	(select rid, MIN(StartDate) as OldestStartDate, MAX(StartDate) as NewestStartDate from dbo.Incentive
				where Active = 1 group by rid) id
	on			id.RID = r.rid
	WHERE		m.MetroAreaID<> 1 and r.RestStateID = 1				



GO

GRANT EXECUTE ON Report_MarketingPOP to ExecuteOnlyRole
GO

GRANT EXECUTE ON Report_MarketingPOP to DTR_User
GO