if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBSample_SampleProc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBSample_SampleProc]
GO


CREATE PROCEDURE dbo.DBSample_SampleProc

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


--**********************************************
--** This proc does nothing 
--**********************************************
	
GO

GRANT EXECUTE ON [DBSample_SampleProc] TO ExecuteOnlyRole

GO
