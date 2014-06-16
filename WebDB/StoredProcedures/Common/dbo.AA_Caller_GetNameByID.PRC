if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_Caller_GetNameByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_Caller_GetNameByID]
GO

CREATE PROCEDURE dbo.AA_Caller_GetNameByID

@CallerID int

 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select FName + ' ' + LName as CallerName from Caller where CallerID =  @CallerID
GO

GRANT EXECUTE ON [AA_Caller_GetNameByID] TO ExecuteOnlyRole

GO
