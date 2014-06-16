if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_ErrorStringGetByLanguageID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_ErrorStringGetByLanguageID]
GO

--**************************************
--** Consider OBSOLETEing this proc. Used in one place
--**	web\CHARM\XML\soap.asp
--**	SRC\CHARM\Admin\XMLWrapper.cls(409): 
--**************************************
CREATE PROCEDURE dbo.XML_ErrorStringGetByLanguageID
(
  @languageID int,
  @errorID int
,@retVal nvarchar(255) OUTPUT
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select @retVal = ErrorMessage
from ErrorMessage
where ErrorID=@errorID

if @retVal is null 
	select @retVal = ErrorMessage
	from ErrorMessage
	where ErrorID=1
GO

GRANT EXECUTE ON [XML_ErrorStringGetByLanguageID] TO ExecuteOnlyRole

GO
