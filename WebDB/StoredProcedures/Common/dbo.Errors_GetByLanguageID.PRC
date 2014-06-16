if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Errors_GetByLanguageID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Errors_GetByLanguageID]
GO





CREATE Procedure dbo.Errors_GetByLanguageID
(
@languageID int
)
AS
SET NOCOUNT ON

--******************************
--** This proc should be OBSOLETE
--** still referenced in 
--**	web\CHARM\global.asa(39):	Set rs2 = helper.RunSQLReturnRS("execute Errors_GetByLanguageID 1",0)
--**	web\CHARM\navigation\common.asp(269):	Set rs2 = helper.RunSQLReturnRS("execute Errors_GetByLanguageID 1",0)
--**	web\OpenTable4\caching.asp(42):			Set rs2 = helper.RunSQLReturnRS("execute Errors_GetByLanguageID " & Cstr(rs1("language_id")))
--******************************


select ErrorID as error_id,ErrorMessage as error_message
from ErrorMessage
order by ErrorID
GO

GRANT EXECUTE ON [Errors_GetByLanguageID] TO ExecuteOnlyRole

GO
