if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListSynchronizeMetroList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListSynchronizeMetroList]
GO



CREATE PROCEDURE [dbo].[TopTenListSynchronizeMetroList] as
/* 
This stored proc is intended to keep the TopTenList MostBooked
lists synchronized with active metros.
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
Begin comparison of MetroArea to TopTenListType (MostBooked) and TopTenList
The join between MetroArea and TopTenListType creates a list that contains
all active metros that and their MostBooked list types.  This list is then
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
				,NULL
				,NULL
				,GETDATE()
				,@procname
FROM			dbo.MetroAreaVW mv
INNER JOIN		TopTenListType ttlt
ON				ttlt.TopTenListTypeClassID = 5 --MostBooked, this join forms a cartesian product between MetroArea and TopTenListType on most booked lists
LEFT JOIN		dbo.TopTenList ttl
ON				mv.MetroAreaID = ttl.MetroAreaID
AND				ttlt.TopTenListTypeID = ttl.TopTenListTypeID
WHERE			mv.Active = 1
AND				ttl.TopTenListTypeID IS NULL			  
AND				mv.MetroAreaID NOT IN (1,58,67) --Demoland,Exclusive,Inactiveville

select @error = @@error
if @error != 0 goto ErrHandler

	
/*
Insert the most booked lists for any new metros
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

SELECT		@InsertList = COALESCE(@InsertList + char(13) + char(10), '') + CAST(MetroAreaID AS VARCHAR) + ',' + CAST(TopTenListTypeID AS VARCHAR)
FROM		@worklist

--Do we need to log anything?
IF LEN(@InsertList) > 0
BEGIN
	SET @LogMsg = 'Added the following metro,mostbookedtype lists to the TopTenList table ' + @InsertList
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END


/*
write to audit log table for the CHARM sync
*/


INSERT INTO		OTTopTenSchemaAudit
				(
				 MetroAreaID
				,OperationTypeID
				)
SELECT			 DISTINCT MetroAreaID
				,1
FROM			@worklist

SELECT @error = @@error
if @error != 0 goto ErrHandler

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
raiserror('Error encountered during TopTenListSynchronizeMetroList',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [TopTenListSynchronizeMetroList] to executeonlyrole

go


