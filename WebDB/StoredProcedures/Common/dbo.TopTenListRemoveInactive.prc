if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListRemoveInactive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListRemoveInactive]
GO



CREATE PROCEDURE [dbo].[TopTenListRemoveInactive] as
/* 
Proc to eliminate any unused TopTenList records due to either
a change to inactive or removal to a metro or inactivating a
macro neighborhood.
*/

SET NOCOUNT ON
DECLARE @error INT

DECLARE @procname VARCHAR(128)

SET @procname = OBJECT_NAME(@@PROCID)

DECLARE @worklist TABLE
(	
	 TopTenListID INT PRIMARY KEY
	,TopTenListTypeID INT
	,ListName NVARCHAR(100)
	,MetroAreaID INT
	,MetroAreaName NVARCHAR(255)
	,MacroID INT
	,MacroName NVARCHAR(100)
	,MetroActive BIT
	,MacroActive BIT
)		


/*
Find any TopTenList records that have inactive geo entities
*/
BEGIN TRANSACTION

INSERT INTO @worklist
(
				 TopTenListID
				,TopTenListTypeID
				,ListName
				,MetroAreaID
				,MetroAreaName
				,MacroID
				,MacroName
				,MetroActive
				,MacroActive				
)
SELECT			 ttl.TopTenListID
				,ttl.TopTenListTypeID
				,ttlt.ListName
				,mv.MetroAreaID
				,mv.MetroAreaName
				,mnv.MacroID
				,mnv.MacroName
				,mv.Active
				,mnv.Active
FROM			dbo.TopTenList ttl
INNER JOIN		dbo.TopTenListType ttlt
ON				ttl.TopTenListTypeID = ttlt.TopTenListTypeID
LEFT JOIN		dbo.TopTenListInstance ttli
ON				ttl.TopTenListID = ttli.TopTenListID
INNER JOIN		dbo.MetroAreaVW mv
ON				ttl.MetroAreaID = mv.MetroAreaID
LEFT JOIN		dbo.MacroNeighborhoodVW mnv
ON				ttl.MacroID = mnv.MacroID
WHERE			ttli.TopTenListID IS NULL
AND				(
					mv.Active = 0
					OR
					ISNULL(mnv.Active,1) = 0
				)
AND				mv.MetroAreaID NOT IN (1,58,67) --Demoland','Exclusive','Inactiveville'

select @error = @@error
if @error != 0 goto ErrHandler

/* Make sure to remove any records from TopTenListRestaurantSupression since we'll get a 
   FK constraint error if we don't*/
DELETE		dbo.TopTenListRestaurantSuppression
FROM		dbo.TopTenListRestaurantSuppression
INNER JOIN	@worklist wl
ON			wl.TopTenListID = dbo.TopTenListRestaurantSuppression.TopTenListID

select @error = @@error
if @error != 0 goto ErrHandler
	
/*
Remove the top ten lists that exist in the @worklist
*/	

DELETE		dbo.TopTenList
FROM		dbo.TopTenList
INNER JOIN	@worklist wl
ON			wl.TopTenListID = dbo.TopTenList.TopTenListID

SELECT @error = @@error
if @error != 0 goto ErrHandler

-- Log the delete event
DECLARE @DeleteList NVARCHAR(3500)
DECLARE @LogMsg NVARCHAR(4000)

SELECT		@DeleteList = COALESCE(@DeleteList + CHAR(10) + CHAR(13), '') + MetroAreaName + ',' + MacroName + ',' + ListName
FROM		@worklist

--Do we need to log anything?
IF LEN(@DeleteList) > 0
BEGIN
	SET @LogMsg = 'Removing the following Metro,Macro,ListName lists from the TopTenList table ' + @DeleteList
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END


/*
Deactivate any metros or macros in the CHARM sync
*/
-- First the regions
INSERT INTO		OTTopTenSchemaAudit
				(
				 MacroID
				,OperationTypeID
				)
SELECT			 DISTINCT MacroID
				,3
FROM			@worklist
WHERE			ISNULL(MacroActive,0) = 0

SELECT @error = @@error
if @error != 0 goto ErrHandler

--Next the metros
INSERT INTO		OTTopTenSchemaAudit
				(
				 MetroAreaID
				,OperationTypeID
				)
SELECT			 DISTINCT MetroAreaID
				,3
FROM			@worklist
WHERE			ISNULL(MetroActive,0) = 0

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
raiserror('Error encountered in proc TopTenListRemoveInactive',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [TopTenListRemoveInactive] to executeonlyrole

go


