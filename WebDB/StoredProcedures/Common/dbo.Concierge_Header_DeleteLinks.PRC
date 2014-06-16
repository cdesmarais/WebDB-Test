if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_DeleteLinks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_DeleteLinks]
GO



CREATE PROCEDURE dbo.Concierge_Header_DeleteLinks
 (
  @Header_ID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

Delete from CallerHeaderLinks where HeaderID = @Header_ID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_DeleteLinks] TO ExecuteOnlyRole

GO
