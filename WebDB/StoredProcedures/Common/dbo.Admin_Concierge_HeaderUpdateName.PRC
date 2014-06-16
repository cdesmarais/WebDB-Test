if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_HeaderUpdateName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_HeaderUpdateName]
GO




CREATE PROCEDURE dbo.Admin_Concierge_HeaderUpdateName
 (
  @Name nvarchar(255),
  @Header_ID int
 )
As
SET NOCOUNT ON
UPDATE CallerHeaders
SET HeaderName = @Name
WHERE HeaderID =  @Header_ID

GO

GRANT EXECUTE ON [Admin_Concierge_HeaderUpdateName] TO ExecuteOnlyRole

GO
