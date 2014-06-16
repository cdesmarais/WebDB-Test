if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_DeleteHeader]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_DeleteHeader]
GO



CREATE PROCEDURE dbo.Concierge_Header_DeleteHeader
 (
  @User_ID int,
  @Header_ID int,
  @Custom int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

Delete from CallertoHeader where HeaderID = @Header_ID and CallerID = @User_ID
if (@@ERROR <> 0)
	goto general_error
if @Custom = 1
BEGIN
	Delete from CallerHeaderLinks where HeaderID = @Header_ID
	Delete from CallerHeaders where HeaderID = @Header_ID
END

if (@@ERROR <> 0)
	goto general_error


COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_DeleteHeader] TO ExecuteOnlyRole

GO
