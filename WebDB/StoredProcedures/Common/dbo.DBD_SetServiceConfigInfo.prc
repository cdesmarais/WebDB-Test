if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_SetServiceConfigInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_SetServiceConfigInfo]
GO


CREATE PROCEDURE dbo.DBD_SetServiceConfigInfo
(
		@theServerID int,
		@theServiceID int,
		@theRuntimeConfig ntext
)
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- check if we are updating or inserting a record..
if exists(select * from runtimeserviceconfig where serverid=@theServerID and serviceid=@theServiceID)
		BEGIN
			update runtimeserviceconfig set runtimeconfig=@theRuntimeConfig,datets=getdate() where serverid=@theServerID and serviceid=@theServiceID
		END

ELSE
		BEGIN
			-- need to insert..
			insert into runtimeserviceconfig values(@theServiceID,@theServerID,@theRuntimeConfig,getdate())

		END

GO


GRANT EXECUTE ON [DBD_SetServiceConfigInfo] TO ExecuteOnlyRole

GO
