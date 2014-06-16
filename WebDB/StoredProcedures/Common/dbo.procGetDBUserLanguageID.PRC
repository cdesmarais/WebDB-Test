if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetDBUserLanguageID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetDBUserLanguageID]
GO

CREATE Procedure dbo.procGetDBUserLanguageID
as
--**************************************************
--** procGetDBUserLanguageID: 
--**					Internal Helper function used to retrieve active language for the user
--**					proc returns one and only one language; returns error if more than one language assocaited with user
--**					proc is intended to be used primarily by Admin procs or procs that insert or update data in the DB
--**************************************************
begin
	declare @retval int

	select	DISTINCT @retval = LanguageId 
	from	DBUser db 
	where	db.dbuser = User

	--Force an Error if more than one language supported
	if @@rowcount > 1
		raiserror('DB User supports more than one language supported', 16, 1)
	--Force an Error if no language returned
	else if @retval is null
		raiserror('DB User supports no languages', 16, 1)
	else
	 	return Isnull(@retval,-1)
end
go


  GRANT EXECUTE ON [procGetDBUserLanguageID] TO ExecuteOnlyRole
  GRANT EXECUTE ON [procGetDBUserLanguageID] TO MonitorUser

go
