
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Job_Check_BatchStatusID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Job_Check_BatchStatusID]
GO


CREATE PROCEDURE [dbo].[Job_Check_BatchStatusID]

As
SET NOCOUNT ON
set transaction isolation level read uncommitted

-- If the BatchStatusID = 1, continue processing; otherwise raise an error because the 
-- Finance Extract job is using this table.

if (select BatchStatusID from OTRPBatch where bid in (select max(bid) from OTRPBatch)) <> 1
	RAISERROR (N'BatchStatusID is not 1. Process aborts.', 16, 1) 


GO


GRANT  EXECUTE  ON [dbo].[Job_Check_BatchStatusID] TO [ExecuteOnlyRole]
GO

