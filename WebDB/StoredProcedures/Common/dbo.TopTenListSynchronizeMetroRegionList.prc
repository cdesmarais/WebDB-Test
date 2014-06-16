if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListSynchronizeMetroRegionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListSynchronizeMetroRegionList]
GO



CREATE PROCEDURE [dbo].[TopTenListSynchronizeMetroRegionList] as
/* 
This stored proc is intended to keep the TopTenList Region
lists synchronized with DFF activations.  The region lists
are intended to be metro DC lists, and should not be confused
with regional lists, which are a subset of their metro counterparts.

The lists created in this stored proc are equivalent to the
Regional Best Overall list.
*/

SET NOCOUNT ON
DECLARE @error INT

DECLARE @procname VARCHAR(128), @DefaultListTypeID INT, @DefaultMediaStoreFLID INT

SET @procname = OBJECT_NAME(@@PROCID)
SET @DefaultListTypeID = 22
SET @DefaultMediaStoreFLID = 21

DECLARE @worklist TABLE
(	
	listorder INT,
	ListNameOverride nvarchar(100),
	TopTenListTypeID int NOT NULL,
	ListDisplayOrder int NOT NULL,
	MetroAreaID int NOT NULL,
	MediaStore_FeedListID int NULL,
	MacroID int NULL,
	CuisineID int NULL,
	NeighborhoodID int NULL,
	LastModified datetime NULL,
	LastModifiedBy nvarchar(255),
	TopTenListID int
)		


/*
Begin comparison of regions to TopTenList records.  All active
regions should have a corresponding record in the TopTenList
table if the DFFStartDate is set for the region's metro
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
				,TopTenListID
)
SELECT			 
				mnv.MacroName
				,@DefaultListTypeID
				,(	SELECT COUNT('x') 
					FROM dbo.MacroNeighborhoodVW mnvx
					LEFT JOIN dbo.TopTenList ttlx
					ON mnvx.MacroID = ttlx.MacroID
					AND ttlx.TopTenListTypeID = 22
					WHERE mnv.macroid >= mnvx.macroid
					AND mnv.MetroAreaID = mnvx.MetroAreaID
					AND mnvx.Active = 1
					AND ttlx.MacroID IS NULL
				)
				,mv.MetroAreaID
				,@DefaultMediaStoreFLID
				,mnv.MacroID
				,NULL
				,NULL
				,GETDATE()
				,@procname
				,ttl.TopTenListID --should always be null
FROM			dbo.MetroAreaVW mv
INNER JOIN		dbo.MacroNeighborhoodVw mnv
ON				mv.MetroAreaID = mnv.MetroAreaID
LEFT JOIN		dbo.TopTenList ttl
ON				mnv.MacroID = ttl.MacroID
AND				ttl.TopTenListTypeID = 22
WHERE			mv.Active = 1
AND				mnv.Active = 1
AND				ttl.MacroID IS NULL	
AND				mv.DFFStartDT IS NOT NULL		  
AND				mv.MetroAreaID NOT IN (1,58,67) --Demoland,Exclusive,Inactiveville
ORDER BY		mv.MetroAreaID, mnv.MacroID

select @error = @@error
if @error != 0 goto ErrHandler

	
/*
Insert the region lists with the display order at the end
of the lists for this metro
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
				,ListDisplayOrder +	(SELECT MAX(ListDisplayOrder) 
									 FROM TopTenList ttl 
									 WHERE ttl.MetroAreaID = wl.MetroAreaID
									 )
				,MetroAreaID
				,MediaStore_FeedListID
				,MacroID
				,CuisineID
				,NeighborhoodID
				,LastModified
				,LastModifiedBy
FROM			@worklist wl

SELECT @error = @@error
if @error != 0 goto ErrHandler

-- Log the insert event
DECLARE @InsertList NVARCHAR(3500)
DECLARE @LogMsg NVARCHAR(4000) --if our message is larger than 8K this will fail

SELECT		@InsertList = COALESCE(@InsertList + char(10) + char(13), '') + CAST(MetroAreaID AS VARCHAR) + ',' + CAST(MacroID AS VARCHAR)
FROM		@worklist

--Do we need to log anything?
IF LEN(@InsertList) > 0
BEGIN
	SET @LogMsg = 'Added the following metro,macro lists to the TopTenList table ' + @InsertList
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END


/*
Write to audit log table for the CHARM sync
*/
INSERT INTO		OTTopTenSchemaAudit
				(
				 MacroID
				,OperationTypeID
				)
SELECT			 DISTINCT MacroID
				,1
FROM			@worklist

SELECT @error = @@error
if @error != 0 goto ErrHandler

/*****************************************************************************
Now test for Region names that have changed
*****************************************************************************/
--Clear out the worklist temp table
DELETE FROM @worklist

/* Get all of the lists where the region name is not the same as the list name override*/
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
				,TopTenListID
)
SELECT			 mnv.MacroName
				,ttl.TopTenListTypeID
				,ttl.ListDisplayOrder
				,mv.MetroAreaID
				,ttl.MediaStore_FeedListID
				,mnv.MacroID
				,NULL
				,NULL
				,GETDATE()
				,@procname
				,ttl.TopTenListID
FROM			dbo.MetroAreaVW mv
INNER JOIN		dbo.MacroNeighborhoodVw mnv
ON				mv.MetroAreaID = mnv.MetroAreaID
INNER JOIN		dbo.TopTenList ttl
ON				mnv.MacroID = ttl.MacroID
WHERE			mv.Active = 1
AND				mnv.Active = 1
AND				mnv.MacroName != isnull(ttl.ListNameOverride,'') COLLATE DATABASE_DEFAULT
AND				ttl.TopTenListTypeID = 22 -- only regional lists
AND				mv.DFFStartDT IS NOT NULL		  
AND				mv.MetroAreaID NOT IN (1,58,67) --Demoland,Exclusive,Inactiveville
ORDER BY		mv.MetroAreaID, mnv.MacroID

SELECT @error = @@error
if @error != 0 goto ErrHandler

--Update the region names that have changed
UPDATE			ttl
SET				ttl.ListNameOverride = wl.ListNameOverride
FROM			dbo.TopTenList ttl
INNER JOIN		@worklist wl
ON				ttl.TopTenListID = wl.TopTenListID

SELECT @error = @@error
if @error != 0 goto ErrHandler

--Log the update event
DECLARE @UpdateList NVARCHAR(3500)
DECLARE @UpLogMsg NVARCHAR(4000)

SELECT		@UpdateList = COALESCE(@UpdateList + CHAR(10) + CHAR(13), '') + CAST(MacroID AS VARCHAR) + ',' + CAST(ListNameOverride AS VARCHAR)
FROM		@worklist

--Do we need to log anything?
IF LEN(@UpdateList) > 0
BEGIN
	SET @UpLogMsg = 'Updated the following MacroID,MacroNames in the TopTenList table ' + @UpdateList
	exec DNErrorAdd
		@Errorid = 6005, 
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
		@Errorid = 6005, 
		@ErrMsg = @error, 
		@ErrStackTrace = @procname,
		@ErrSeverity = 2
raiserror('Error encountered during TopTenListSynchronizeMetroRegionList',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [TopTenListSynchronizeMetroRegionList] to executeonlyrole

go

