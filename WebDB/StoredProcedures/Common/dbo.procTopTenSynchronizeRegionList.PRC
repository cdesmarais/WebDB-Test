if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procTopTenListSynchronizeRegionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procTopTenListSynchronizeRegionList]
GO



CREATE PROCEDURE [dbo].[procTopTenListSynchronizeRegionList]
(
@UseDFFDate bit = 1
)
as
/* 
This proc synchronizes regional lists. For EU and Asia we disregard
the DFFStartDate since DFF is not currently active there.  The metro
must be marked as ShowRegionalLists=1 and have valid matching metro
level lists in the TopTenList table.
*/

SET NOCOUNT ON
DECLARE @error INT, @DefaultRegionListType INT
SET @DefaultRegionListType = 22

DECLARE @procname VARCHAR(128)

SET @procname = OBJECT_NAME(@@PROCID)

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
	LastModifiedBy nvarchar(255)
)		


/*
Find metro level lists that don't exist at a regional level for 
metros that have the 'ShowRegionaLists' bit turned on
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
SELECT			 
				NULL
				,ttl.TopTenListTypeID
				,0
				,mv.MetroAreaID
				,ttlt.MediaStore_FeedListID
				,mnv.MacroID
				,ttl.CuisineID
				,ttl.NeighborhoodID
				,GETDATE()
				,@procname
FROM			dbo.TopTenListType ttlt
INNER JOIN		dbo.TopTenList ttl
ON				ttlt.TopTenListTypeID = ttl.TopTenListTypeID
INNER JOIN		dbo.MetroAreaVW mv
ON				ttl.MetroAreaID = mv.MetroAreaID
INNER JOIN		dbo.MacroNeighborhoodVW mnv
ON				mv.MetroAreaID = mnv.MetroAreaID
LEFT JOIN		TopTenList ttl2
ON				mnv.MacroID = ttl2.MacroID
AND				ttl.TopTenListTypeID = ttl2.TopTenListTypeID
WHERE			ttlt.TopTenListTypeID != @DefaultRegionListType
AND				ttl2.MacroID IS NULL
AND				ttl.MacroID IS NULL --We only want metro level lists
AND				mv.ShowRegionLists = 1
AND				mv.Active = 1
AND				mnv.Active = 1
and				((@UseDFFDate = 1 and mv.DFFStartDT is not null) or @UseDFFDate = 0)
ORDER BY 		ttl.metroareaid, ttl.ListDisplayOrder

select @error = @@error
if @error != 0 goto ErrHandler

	
/*
Insert the regional level lists
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
FROM			@worklist wl

SELECT @error = @@error
if @error != 0 goto ErrHandler

-- Log the insert event
DECLARE @InsertList NVARCHAR(3500)
DECLARE @LogMsg NVARCHAR(4000)

SELECT		@InsertList = COALESCE(@InsertList + CHAR(10) + CHAR(13), '') + CAST(MacroID AS VARCHAR) + ',' + CAST(TopTenListTypeID AS VARCHAR)
FROM		@worklist

--Do we need to log anything?
IF LEN(@InsertList) > 0
BEGIN
	SET @LogMsg = 'Added the following macro,category lists to the TopTenList table ' + @InsertList
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END


/*
No need to write anything to the CHARM sync interface
*/

--success
COMMIT
GOTO TheEnd

ErrHandler:
	ROLLBACK
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg =  @error,
		@ErrStackTrace = @procname,
		@ErrSeverity = 2
raiserror('Error encountered during procTopTenListSynchronizeRegionList',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [procTopTenListSynchronizeRegionList] to executeonlyrole

go

