if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_GetConfigVals]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_GetConfigVals]
GO


CREATE PROCEDURE dbo.DBD_GetConfigVals
(
		@theServiceID int,
		@theServerID int
)
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


-- get pristing config first..
select serviceconfig from serviceconfig where serviceid=@theSErviceID

-- get the runtime config..
select runtimeconfig from runtimeserviceconfig where serviceid=@theServiceID and serverid=@theServerID


GO


GRANT EXECUTE ON [DBD_GetConfigVals] TO ExecuteOnlyRole

GO
