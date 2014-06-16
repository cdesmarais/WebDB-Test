if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListReorder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListReorder]
GO



CREATE PROCEDURE [dbo].[TopTenListReorder] as
/* 
This stored proc is intended to keep the TopTenList.ListDisplayOrder ordinal
*/

SET NOCOUNT ON
DECLARE @error INT

DECLARE @procname VARCHAR(128)

SET @procname = OBJECT_NAME(@@PROCID)

DECLARE @worklist TABLE
(	
	 MetroAreaID INT
	,MetroListCount INT
	,MaxListDisplayOrder INT
)		

/*
Put the counts and max order into the
worklist by metroid
*/
BEGIN TRANSACTION

INSERT INTO @worklist
(				
				 MetroAreaID
				,MetroListCount
				,MaxListDisplayOrder
)
SELECT			 MetroAreaID
				,COUNT('x')
				,MAX(ListDisplayOrder)
FROM			dbo.TopTenList
WHERE			(MacroID IS NULL OR TopTenListTypeID = 22)
GROUP BY		MetroAreaID
ORDER BY		MetroAreaID

select @error = @@error
if @error != 0 goto ErrHandler

--Iterate through the worklist and exec the reorder proc for all of the metros
--that need reordering
DECLARE @MetroIdToReorder INT

DECLARE reorder CURSOR FOR
	SELECT MetroAreaID
	FROM @worklist
	WHERE MaxListDisplayOrder != MetroListCount

OPEN reorder
FETCH NEXT FROM reorder
INTO @MetroIdToReorder

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC procTopTenReorderMetroAreaLists @MetroIdToReorder
	IF @@ERROR <> 0
		GOTO ErrHandler
		
	FETCH NEXT FROM reorder
	INTO @MetroIDToReorder
END

CLOSE reorder
DEALLOCATE reorder


DECLARE @ReorderList NVARCHAR(3500)
DECLARE @LogMsg NVARCHAR(4000)

SELECT		@ReorderList = COALESCE(@ReorderList + ',', '') + CAST(MetroAreaID AS VARCHAR)
FROM		@worklist
WHERE		MaxListDisplayOrder != MetroListCount

--Do we need to log anything?
IF LEN(@ReorderList) > 0
BEGIN
	SET @LogMsg = 'Reorderd the following metros lists in the TopTenList table ' + @ReorderList
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END


/*
not a schema audit event
*/

--success
COMMIT
GOTO TheEnd

ErrHandler:
	CLOSE reorder
	DEALLOCATE reorder

	ROLLBACK
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @error, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
raiserror('Error encountered during TopTenListReorder',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [TopTenListReorder] to executeonlyrole

go


