if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListTypeSynchronizeCuisine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListTypeSynchronizeCuisine]
GO



CREATE PROCEDURE [dbo].[TopTenListTypeSynchronizeCuisine] as
/* 
This stored proc is intended to keep the TopTenListType table
in sync with macro food types.  It will create a record
for each new food type it finds, and update any existing
records when the food type description has changed.
*/

SET NOCOUNT ON
DECLARE @ListTypeClassID INT, @MS_FeedListID INT, @Override INT, 
@MaxListDisplayOrder INT, @error INT

DECLARE @procname VARCHAR(128)

--Add the default list order to the end of the current records
SELECT @MaxListDisplayOrder = MAX(DefaultDisplayOrder) FROM TopTenListType 

--Since we're only dealing with cuisines the TopTenListTypeClassID 
--and MediaStore_FeedListID remain constant
SET @ListTypeClassID = 2
SET @MS_FeedListID = 20
SET @Override = 0

SET @procname = OBJECT_NAME(@@PROCID)

DECLARE @worklist TABLE
(
	TempListDisplayOrder INT IDENTITY PRIMARY KEY,
	ListName NVARCHAR(100),
	ListDisplayOrderNationalOverride INT,
	TopTenListTypeClassID INT,
	CuisineID INT,
	MediaStore_FeedListID INT,
	TopTenListTypeID INT
)		


/*
Begin comparison of food types and top ten list types
*/
BEGIN TRANSACTION

INSERT INTO @worklist
(				
				 ListName
				,ListDisplayOrderNationalOverride
				,TopTenListTypeClassID
				,CuisineID
				,MediaStore_FeedListID
				,TopTenListTypeID
)
SELECT			 ft.FoodType
				,@Override
				,@ListTypeClassID
				,ft.FoodTypeID
				,@MS_FeedListID
				,ttlt.TopTenListTypeID
FROM			FoodType ft
inner join		dbo.DBUserDistinctLanguageVW db 
on				db.languageid = ft.LanguageID
LEFT JOIN		dbo.TopTenListType ttlt
ON				ft.FoodTypeID = ttlt.CuisineID
WHERE			ft.FoodTypeID = ft.SFTID
AND				(
					ttlt.TopTenListTypeID IS NULL 
					OR 
					ISNULL(ttlt.ListName,'') != ft.FoodType COLLATE DATABASE_DEFAULT
					
				)

select @error = @@error
if @error != 0 goto ErrHandler


/*
update any list types that don't match its corresponding food type
*/

UPDATE ttlt
SET ttlt.ListName = wl.ListName
FROM dbo.TopTenListType ttlt
INNER JOIN @worklist wl
ON ttlt.TopTenListTypeID = wl.TopTenListTypeID

select @error = @@error
if @error != 0 goto ErrHandler

--Now log the event (if needed)
DECLARE @LogMsg NVARCHAR(4000)
DECLARE @AfterList NVARCHAR(3500)

SELECT		@AfterList = COALESCE(@AfterList+ char(13) + char(10),'') + wl.CuisineID
FROM dbo.TopTenListType ttlt
INNER JOIN @worklist wl
ON ttlt.TopTenListTypeID = wl.TopTenListTypeID

--Do we need to log anything?
IF LEN(@AfterList) > 0
BEGIN
	SET @LogMsg = 'FoodType has been updated. The TopTenListType.ListName data was updated for the following food types ' + @AfterList
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END

-- There will be no CHARM sync for list name updates
	
/*
Now do the inserts of any new cuisines
*/	


INSERT INTO		dbo.TopTenListType 
				(ListName
				,ListDisplayOrderNationalOverride
				,TopTenListTypeClassID
				,CuisineID
				,DefaultDisplayOrder
				,MediaStore_FeedListID
				)
SELECT			 ListName
				,ListDisplayOrderNationalOverride
				,TopTenListTypeClassID
				,CuisineID
				,TempListDisplayOrder + @MaxListDisplayOrder
				,MediaStore_FeedListID
FROM			@worklist
WHERE			TopTenListTypeID IS NULL

select @error = @@error
if @error != 0 goto ErrHandler

-- Log the insert event
DECLARE @InsertList NVARCHAR(3500)

SELECT		@InsertList = COALESCE(@InsertList + char(13) + char(10), '') + ListName
FROM		@worklist
WHERE		TopTenListTypeID IS NULL

--Do we need to log anything?
IF LEN(@InsertList) > 0
BEGIN
	SET @LogMsg = 'Added the following cuisines to the TopTenListType table ' + @InsertList
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
				 CuisineID
				,OperationTypeID
				)
SELECT			 CuisineID
				,1
FROM			@worklist
WHERE			TopTenListTypeID IS NULL

select @error = @@error
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
raiserror('Error encountered during TopTenListTypeSynchronizeCuisine',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [TopTenListTypeSynchronizeCuisine] to executeonlyrole

go


