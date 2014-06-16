if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListSynchronizeCategoryList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListSynchronizeCategoryList]
GO



CREATE PROCEDURE [dbo].[TopTenListSynchronizeCategoryList] as
/* 
This stored proc is intended to keep the TopTenList Category
lists synchronized with DFF activations.  The category lists
essentially entail all list records that are not most booked or
regional.
*/

SET NOCOUNT ON
DECLARE @error INT

DECLARE @procname VARCHAR(128)

SET @procname = OBJECT_NAME(@@PROCID)

DECLARE @worklist TABLE
(	
	ListNameOverride nvarchar(100),
	TopTenListTypeID int NOT NULL,
	ListDisplayOrder int NOT NULL,
	MetroAreaID int NOT NULL,
	MediaStore_FeedListID int NULL,
	MacroID int NULL,
	CuisineID int NULL,
	NeighborhoodID int NULL,
	LastModified datetime NULL,
	LastModifiedBy nvarchar(255)
)		


/*
Begin comparison of MetroArea to TopTenListType (non MostBooked and regional) 
and TopTenList. The join between MetroArea and TopTenListType creates a list that contains
all active metros that and their catetory list types.  This list is then
compared against TopTenList to see which are missing.
*/

BEGIN TRANSACTION

INSERT INTO @worklist
(				
				 ListNameOverride
				,TopTenListTypeID
				,ListDisplayOrder
				,MetroAreaID
				,MediaStore_FeedListID
				,MacroID
				,CuisineID
				,NeighborhoodID
				,LastModified
				,LastModifiedBy
)
SELECT			 NULL
				,ttlt.TopTenListTypeID
				,ttlt.DefaultDisplayOrder
				,mv.MetroAreaID
				,ttlt.MediaStore_FeedListID
				,NULL
				,ttlt.CuisineID
				,NULL
				,GETDATE()
				,@procname
FROM			dbo.MetroAreaVW mv
INNER JOIN		dbo.TopTenListType ttlt
ON				mv.DFFStartDT IS NOT NULL --This join forms a cartesian product between the metro and list type tables to be compared against the toptenlist table
AND				ttlt.TopTenListTypeClassID NOT IN (4,5) -- No region or most booked
LEFT JOIN		dbo.TopTenList ttl
ON				ttlt.TopTenListTypeID = ttl.TopTenListTypeID
AND				mv.MetroAreaID = ttl.MetroAreaID
AND				0 = ISNULL(ttl.macroid,0) --Since we're not sync'ing macro lists here don't let any regional level category lists eliminate records
WHERE			ttl.TopTenListTypeID IS NULL
AND				mv.MetroAreaID NOT IN (1,58,67) --Demoland,Exclusive,Inactiveville
AND				mv.Active = 1
ORDER BY		mv.MetroAreaID, ttlt.ListName


select @error = @@error
if @error != 0 goto ErrHandler

	
/*
Insert any new category lists
*/	

INSERT INTO		dbo.TopTenList
(
				 ListNameOverride
				,TopTenListTypeID
				,ListDisplayOrder
				,MetroAreaID
				,MediaStore_FeedListID
				,MacroID
				,CuisineID
				,NeighborhoodID
				,LastModified
				,LastModifiedBy
)
SELECT			 ListNameOverride
				,TopTenListTypeID
				,ListDisplayOrder
				,MetroAreaID
				,MediaStore_FeedListID
				,MacroID
				,CuisineID
				,NeighborhoodID
				,LastModified
				,LastModifiedBy
FROM			@worklist

SELECT @error = @@error
if @error != 0 goto ErrHandler

-- Log the insert event
DECLARE @InsertList NVARCHAR(3500)
DECLARE @LogMsg NVARCHAR(4000)

SELECT		@InsertList = COALESCE(@InsertList + CHAR(10) + CHAR(13), '') + CAST(MetroAreaID AS VARCHAR) + ',' + CAST(TopTenListTypeID AS VARCHAR)
FROM		@worklist

--Do we need to log anything?
IF LEN(@InsertList) > 0
BEGIN
	SET @LogMsg = 'Added the following metro,category lists to the TopTenList table ' + @InsertList
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END


/*
No need to write to audit log table for the CHARM sync
*/

--success
COMMIT
GOTO TheEnd

ErrHandler:
	ROLLBACK
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @error, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
raiserror('Error encountered during TopTenListSynchronizeCategoryList',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [TopTenListSynchronizeCategoryList] to executeonlyrole

go


