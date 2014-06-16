if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetErrorDrops]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetErrorDrops]
GO




CREATE PROCEDURE dbo.Admin_GetErrorDrops
(  
  @type int,
  @lanscreen int = 0
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
if @type = 0
    Begin
    Select ErrorTypeID as error_type_id,ErrorTypeDesc as error_type_description
    From ErrorType
    Return(0)
    End
if @type = 1
    Begin
    Select '1' as LanguageID,'English' as Name
 
    Return(1)
    End

GO

GRANT EXECUTE ON [Admin_GetErrorDrops] TO ExecuteOnlyRole

GO
