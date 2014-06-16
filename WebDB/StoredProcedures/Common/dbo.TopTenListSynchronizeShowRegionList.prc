if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListSynchronizeShowRegionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListSynchronizeShowRegionList]
GO

CREATE PROCEDURE [dbo].[TopTenListSynchronizeShowRegionList] as
/* 
This stored proc is intended to keep the MetroArea.ShowRegionList
bit value in sync with the metros in the OTMediaStore database that
should generate top  ten lists for regions.
*/

SET NOCOUNT ON
DECLARE @error INT,@count INT

DECLARE @procname VARCHAR(128)
DECLARE @Activate INT, @Deactivate INT
DECLARE @LogMsg VARCHAR(500);
SET @Activate = 5
SET @Deactivate = 6

SET @procname = OBJECT_NAME(@@PROCID)

BEGIN TRANSACTION
/*
First determine which metros have the bit on, but the latest CHARM sync
event is not a region list activation - meaning that the OTTopTenSchemaAudit
values are missing for the region list activation or deactivation, or the latest
value is a deactivation.
*/
INSERT INTO		OTTopTenSchemaAudit
(				
				 MetroAreaID
				,OperationTypeID
)
SELECT			 mv.MetroAreaID
				,@Activate
FROM			dbo.MetroAreaVW mv
LEFT JOIN		OTTopTenSchemaAudit ota
ON				mv.MetroAreaID = ota.MetroAreaID
AND				ota.OperationTypeID IN (@Activate,@Deactivate)
WHERE			mv.ShowRegionLists = 1
AND				(ota.MetroAreaID IS NULL
				 OR
					(ota.OTTopTenSchemaAuditID = (	SELECT TOP	1 OTTopTenSchemaAuditID 
													FROM		OTTopTenSchemaAudit otax
													WHERE		otax.MetroAreaID = mv.MetroAreaID
													AND			otax.OperationTypeID IN (@Activate,@Deactivate)
													ORDER BY	otax.OTTopTenSchemaAuditID DESC
												 )
					 AND ota.OperationTypeID = @Deactivate
					)
				)

select @error = @@ERROR, @count = @@ROWCOUNT
if @error != 0 goto ErrHandler

--Log how many records were activated
IF @count > 0
BEGIN	
	SET @LogMsg = 'Activated ' + CAST(@count AS VARCHAR) + ' metros for regional lists'
	exec DNErrorAdd
		@Errorid = 6005, 
		@ErrMsg = @LogMsg, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2
END


/*
Now do the reverse.  Determine the metros that do not have the ShowRegionList
bit turned on, but have a OTTopTenSchemaAudit.OperationTypeID = 5 as its last
CHARM sync value for this toggle.
*/
INSERT INTO		OTTopTenSchemaAudit
(				
				 MetroAreaID
				,OperationTypeID
)
SELECT			 mv.MetroAreaID
				,@Deactivate
FROM			dbo.MetroAreaVW mv
INNER JOIN		OTTopTenSchemaAudit ota
ON				mv.MetroAreaID = ota.MetroAreaID
AND				ota.OperationTypeID IN (@Activate,@Deactivate)
WHERE			mv.ShowRegionLists = 0
AND				ota.OTTopTenSchemaAuditID = (	SELECT TOP	1 OTTopTenSchemaAuditID 
												FROM		OTTopTenSchemaAudit otax
												WHERE		otax.MetroAreaID = mv.MetroAreaID
												AND			otax.OperationTypeID IN (@Activate,@Deactivate)
												ORDER BY	otax.OTTopTenSchemaAuditID DESC
											)
AND				ota.OperationTypeID = @Activate
				
				
select @error = @@ERROR, @count = @@ROWCOUNT
if @error != 0 goto ErrHandler

--Log how many records were activated
IF @count > 0
BEGIN	
	SET @LogMsg = 'Deactivated ' + CAST(@count AS VARCHAR) + ' metros for regional lists'
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
raiserror('Error encountered during TopTenListSynchronizeShowRegionList',16,1)
return(1)

TheEnd:
RETURN (0)

go

grant execute on [TopTenListSynchronizeShowRegionList] to executeonlyrole

go


