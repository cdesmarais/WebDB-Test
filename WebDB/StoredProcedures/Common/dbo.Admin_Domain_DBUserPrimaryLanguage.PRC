if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Domain_DBUserPrimaryLanguage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Domain_DBUserPrimaryLanguage]
GO

CREATE PROCEDURE dbo.Admin_Domain_DBUserPrimaryLanguage
AS

SET nocount on 
SET TRANSACTION isolation  LEVEL  READ  uncommitted 

if ((select COUNT(DomainID) from DBUser where DBUser = USER) > 1)
	select	distinct u.OpLanguageID as PrimaryLanguageID
	from	DBUser u
	where	u.dbuser = user
else
	select	distinct d.PrimaryLanguageID as PrimaryLanguageID
	from	domain d
	inner join dbuser u on d.DomainID = u.DomainId
	where	u.dbuser = user

GO


GRANT EXECUTE ON [Admin_Domain_DBUserPrimaryLanguage] TO ExecuteOnlyRole

GO

