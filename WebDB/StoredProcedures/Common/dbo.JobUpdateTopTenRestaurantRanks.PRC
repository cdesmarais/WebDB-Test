if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUpdateTopTenRestaurantRanks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUpdateTopTenRestaurantRanks]
GO

create procedure [dbo].[JobUpdateTopTenRestaurantRanks] as

set transaction isolation level read uncommitted
set nocount ON

declare @error int
declare @procname VARCHAR(128)
set @procname = OBJECT_NAME(@@PROCID)

declare @worklist table
(
	MetroAreaID int NOT NULL,
	TopTenListInstanceID int NOT NULL,
	RID int NOT NULL,
	OriginalRank int NOT NULL,
	NewRank int NOT NULL
)

begin transaction

-- Insert the records that need to be re-ranked
insert into @worklist (
	MetroAreaID,
	TopTenListInstanceID,
	RID,
	OriginalRank,
	NewRank
) 
select		a.MetroAreaID
			,a.TopTenListInstanceID
			,a.RID
			,a.Rank
			, count(1) -- new rank
from		TopTenRestaurantVW as a
inner join	TopTenRestaurantVW as b
on			a.TopTenListInstanceID = b.TopTenListInstanceID
and			a.rank>=b.rank
where		a.TopTenListInstanceIsActive = 1 
and			b.TopTenListInstanceIsActive = 1
-- filter out lists without suppressed restaurants.  
-- we are assuming there is nothing to process for those.
and			a.TopTenListInstanceid in 
(
	select distinct ttli.TopTenListInstanceID
	from		TopTenListInstance ttli
	inner join	TopTenImportJob ttij
	on			ttij.TopTenImportJobID			= ttli.TopTenImportJobID
	inner join	TopTenListRestaurantSuppression ttlrs
	on			ttli.TopTenListID				= ttlrs.TopTenListID
	where		coalesce(ttij.Status,1)			= 1
	and			ttli.isactive=1
	and			ttlrs.RID is not null -- is not null (aka. suppressed!)
)
group by	a.MetroAreaID
			,a.TopTenListInstanceID
			,a.RID
			,a.Rank
			,a.NbhoodName
having count(1) <= 10
and a.rank != count(1)

select @error = @@error
if @error != 0 goto ErrHandler

--Update the top ten restaurants that need re-ranking
update		toptenlistrestaurant
set			Rank = c.NewRank
from		toptenlistrestaurant as r
left join	@worklist as c
on			r.TopTenListInstanceID = c.TopTenListInstanceID
and			r.rid=c.rid
where		c.TopTenListInstanceID IS NOT NULL
			AND c.RID IS NOT NULL
			AND c.OriginalRank IS NOT NULL
			AND c.NewRank IS NOT NULL
	
select @error = @@error
if @error != 0 goto ErrHandler

--Delete the suppressed restaurants from the TopTenListRestaurant table
delete 		ttlr
from		TopTenListRestaurant ttlr
inner join	TopTenListInstance ttli on ttlr.TopTenListInstanceID = ttli.TopTenListInstanceID
inner join	TopTenImportJob ttij on ttij.TopTenImportJobID = ttli.TopTenImportJobID
inner join	TopTenListRestaurantSuppression ttlrs on ttli.TopTenListID = ttlrs.TopTenListID
and			ttlr.RID = ttlrs.RID

select @error = @@error
if @error != 0 goto ErrHandler

-- Log the updated records
DECLARE @InsertList NVARCHAR(3500)
DECLARE @LogMsg NVARCHAR(4000)

-- toptenlistinstanceid,rid,newrank,oldrank
select		@InsertList = COALESCE(@InsertList + CHAR(10) + CHAR(13), '') + CAST(MetroAreaID AS VARCHAR) + ',' + CAST(TopTenListInstanceID AS VARCHAR) + ',' + CAST(RID AS VARCHAR) + ',' + CAST(NewRank AS VARCHAR) + ',' + CAST(OriginalRank AS VARCHAR)
from		@worklist ORDER BY MetroAreaID, TopTenListInstanceID, NewRank asc

--Do we need to log anything?
IF LEN(@InsertList) > 0
BEGIN
	SET @LogMsg = 'Updated the rank of the following top ten restaurants: '  + CHAR(10) + CHAR(13) + @InsertList

	exec DNErrorAdd
		@Errorid = 6006, -- TopTenListRestaurantReRankJob
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END

--success
COMMIT
GOTO TheEnd

ErrHandler:
	ROLLBACK
	exec DNErrorAdd
		@Errorid = 6006, -- TopTenListRestaurantReRankJob
		@ErrMsg =  @error,
		@ErrStackTrace = @procname,
		@ErrSeverity = 2
raiserror('Error encountered during JobUpdateTopTenRestaurantRanks',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [JobUpdateTopTenRestaurantRanks] to executeonlyrole

go

