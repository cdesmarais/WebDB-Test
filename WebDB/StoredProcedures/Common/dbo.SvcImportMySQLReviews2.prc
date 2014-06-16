-- Must drop proc before dropping the type
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcImportMySQLReviews2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].SvcImportMySQLReviews2
GO

-- Drop type after reference is removed
if exists(select * from sys.types where name = 'MySqlReviewsImportType2' and is_table_type = 1)
drop type dbo.MySqlReviewsImportType2
go

CREATE TYPE dbo.MySqlReviewsImportType2 AS TABLE
(
	ResID			int not null, 
	OverallRating	int not null,
	ResponseDTUTC	datetime not null,
	ResDt			datetime not null,
	WebRID			int not null,
	CustID			int not null,
	CallerID		int null,
	Comments		nvarchar(800) not null
)
GO

grant execute on type::dbo.MySqlReviewsImportType2 to ExecuteOnlyRole
go

CREATE PROCEDURE dbo.SvcImportMySQLReviews2
(
	@MySqlDataSet dbo.MySqlReviewsImportType2 READONLY
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)

declare @MaxRank int
declare @ReviewsCutoffDate datetime
declare @UTCSysDate datetime
declare @VipConsumerType int  
declare @ReviewInceptionDays int  
declare @ReviewInceptionCutoffDate datetime  
declare	@MinRestaurantOverallRating decimal(5,3)
declare @return int

set @ProcName = 'MySqlReviewsImportType2'
set @VipConsumerType = 4
set @MaxRank = 3
set @UTCSysDate = getutcdate()
set @ReviewsCutoffDate = DATEADD(dd, -10, @UTCSysDate)
set @return = 0

-- Reviews rating display setting
select @MinRestaurantOverallRating = cast(isnull(ValueChar,'3.5') as decimal(5,3))
from ValueLookup   
where LKey = 'StartMinRestReviewRating'
and  LType = 'WEBSERVER'  

-- default to 3.5
if(isnull(@MinRestaurantOverallRating,0)<=0)
	set @MinRestaurantOverallRating = 3.5

--Ratings data display logic  
select @ReviewInceptionDays = ValueInt   
from ValueLookup   
where LKey = 'RestReviewInceptionDays'   
and  LType = 'WEBSERVER'  

set  @ReviewInceptionDays = ISNULL(@ReviewInceptionDays, 30)  
set  @ReviewInceptionCutoffDate = DATEADD(dd, @ReviewInceptionDays*-1, GETDATE())	


-- In order to handle dupe RIDs, we need to create a temp table to handle additional
-- processing and re-ranking after the data clean up
set @Action = 'Creating temp table #FilteredReviewsData'
create table #FilteredReviewsData
(
	ResID				int			not null,
	RID					int			not null,
	OverallRating		int			not null,
	Comments			nvarchar(800)	not null,
	ResponseDTUTC		datetime		not null,
	ResDT				datetime	not null,
	VIP					bit			not null,
	CustID				int			not null,
	CallerID			int			null,
	MetroAreaID			int			not null,
	MacroID				int			not null,
	MacroRank			int			not null
)

if @@error <> 0 
	goto general_error

set @Action = 'Populating temp table #FilteredReviewsData with pre-filtered reviews'
insert into #FilteredReviewsData (ResID,RID,OverallRating,Comments,ResponseDTUTC,ResDT, VIP,CustID,CallerID,MetroAreaID,MacroID,MacroRank)
select		ResID
			,RID
			,OverallRating
			,Comments
			,ResponseDTUTC	
			,ResDT
			,Vip
			,CustID
			,CallerID
			,MetroAreaID
			,MacroID
			-- Now that the reservations have been filtered out and combined,
			-- rank them by macro partitions based on the order defined
			-- Order: review date (desc), over all rating (desc), vip (desc) reviews first
			,row_number()  over(
				partition by MacroID 
				order by dateadd(dd, datediff(dd,0,ResponseDTUTC), 0) desc
					, OverallRating desc
					, Vip desc
			) MacroRank
from (

	-- Gathering the reviews for non-admin customers
	select				my.ResID
						,my.WebRID as RID
						,my.OverallRating
						,my.Comments
						,my.ResponseDTUTC
						,my.ResDT
						,my.CustID
						,my.CallerID
						,n.MetroAreaID
						,n.MacroID
						,(case when(isnull(c.ConsumerType,-1) = @VipConsumerType) then 1 else 0 end) as Vip
	from				@MySqlDataSet as my
	inner join			Restaurant as r
	on					r.rid = my.webrid
	inner join			NeighborhoodVW n 
	on					n.neighborhoodid = r.neighborhoodid
	inner join			Customer as c
	on					c.CustID = my.CustID
	left join 			RestaurantJustAdded rja
	on 					r.RID = rja.RID
	inner join			DFFDailySummaryRIDStatsHolding dff
	on					r.rid = dff.webrid	
	left join			StartPageReviews spr
	on					spr.ResID = my.ResID

						-- Filtering out admin customers
	where				isnull(my.callerid,0) = 0  
						-- Filtering out reviews older than 10 days
	and					my.ResponseDTUTC > @ReviewsCutoffDate
						-- Filtering out reviews for rests just added and still in the inception period
	and					isnull(rja.DateAdded,'2000-01-01') < @ReviewInceptionCutoffDate
						-- Filtering out reviews for rests on the dff blacklist
	and					isnull(dff.BlackListFlag,0) != 1
						-- Filtering out restaurants that don't meet the minimum overall rating
	and					isnull(dff.averageoverallrating, 0) > @MinRestaurantOverallRating
						-- Filtering out suppressed restaurants
	and					isnull(spr.Suppressed,0) != 1
	
	union all
	
	-- Gathering the reviews for admin customers
	select				my.ResID
						,my.WebRID as RID
						,my.OverallRating
						,my.Comments
						,my.ResponseDTUTC
						,my.ResDT
						,my.CustID
						,my.CallerID
						,n.MetroAreaID
						,n.MacroID
						,(case when(isnull(c.ConsumerType,-1) = @VipConsumerType) then 1 else 0 end) as Vip
	from				@MySqlDataSet as my
	inner join			restaurant as r
	on					r.rid = my.webrid
	inner join			Neighborhood n 
	on					n.neighborhoodid = r.neighborhoodid
	inner join			[Caller] as c
	on					c.CallerID = my.CallerID	
	left join 			RestaurantJustAdded rja
	on 					r.RID = rja.RID
	inner join			DFFDailySummaryRIDStatsHolding dff
	on					r.rid = dff.webrid
	left join			StartPageReviews spr
	on					spr.ResID = my.ResID

						-- Filtering out non-admin customers
	where				isnull(my.CallerID,0) > 0  
						-- Filtering out reviews older than 10 days
	and					my.ResponseDTUTC > @ReviewsCutoffDate
						-- Filtering out reviews for rests just added and still in the inception period
	and					isnull(rja.DateAdded,'2000-01-01') < @ReviewInceptionCutoffDate
						-- Filtering out reviews for rests on the dff blacklist
	and					isnull(dff.BlackListFlag,0) != 1
						-- Filtering out restaurants that don't meet the minimum overall rating
	and					isnull(dff.averageoverallrating, 0) > @MinRestaurantOverallRating
						-- Filtering out suppressed restaurants	
	and					isnull(spr.Suppressed,0) != 1
		
) as FilteredData

If @@error <> 0 
	goto general_error

-- We want to only show one review per restaurant, so we need 
-- to clean lower ranked reviews for the same restaurant. 
set @Action = 'Deleting dupe, rid, reviews from temp table #FilteredReviewsData'
delete			#FilteredReviewsData 
where			ResID in 
(
	-- getting a list of resid for reviews that were
	-- submited for the same restaurant.
	select		t.ResID 
	from 
	(
		select		rid
					,min(macrorank) min_rank
		from		#FilteredReviewsData
		group by		RID
		having			count(*) > 1

	) a
	inner join		#FilteredReviewsData t
	on				t.RID = a.rid
	where			MacroRank != min_rank
)

if @@error <> 0 
	goto general_error

begin transaction

-- clear out the previous start page reviews that:
-- 1. Are not supressed
-- 2. Are supressed, but older than (range to be deteremined)
set @Action = 'Clearing out existing start page reviews'
delete StartPageReviews where Suppressed!=1 OR ResponseDateUTC < @ReviewsCutoffDate

if @@error <> 0 
	goto general_error

-- Since the deletion process ruins the previous ranking, 
-- we need to re-rank based on the row order sorted by the 
-- old macro ranking value. We then store the list of ranks 
-- under 4 into the final lookup table.
set @Action = 'Adding final reviews from temp table #FilteredReviewsData to the StartPageReviews table'
insert into StartPageReviews 
(
				ResID
				,RID
				,OverallRating
				,Comments
				,ResponseDateUTC
				,ResDT
				,Suppressed
				,VIP
				,CustID
				,CallerID
)
select			ResID
				,RID
				,OverallRating
				,Comments
				,ResponseDTUTC
				,ResDT
				,0 -- Not Suppressed
				,VIP
				,CustID
				,CallerID
from (
	select		ResID
				,RID
				,OverallRating
				,Comments
				,ResponseDTUTC
				,ResDT
				,VIP
				,CustID
				,CallerID 
				,MetroAreaID
				,MacroID
				,MacroRank
				,row_number()  over(
					partition by MacroID 
					order by MacroRank asc
				) NewMacroRank
	from		#FilteredReviewsData
) FinalReviewsData 
where			NewMacroRank <= @MaxRank
order by		MetroAreaID, MacroID, MacroRank

if @@error <> 0 
	goto general_error

commit transaction
goto finished

general_error:
	rollback transaction
	set @return = -1
	raiserror (@Action,16,1)

finished:
	if object_id('tempdb..#FilteredReviewsData') is not null 
		drop table #FilteredReviewsData	

	return @return
	
go

grant execute on [dbo].SvcImportMySQLReviews2 TO ExecuteOnlyRole

go

