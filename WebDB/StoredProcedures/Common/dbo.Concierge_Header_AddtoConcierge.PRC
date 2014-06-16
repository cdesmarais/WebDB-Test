if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_AddtoConcierge]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_AddtoConcierge]
GO



CREATE PROCEDURE dbo.Concierge_Header_AddtoConcierge
 (
  @Header_ID int,
  @User_ID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

BEGIN
	INSERT INTO CallertoHeader
	 (
	  CallerID,
	  HeaderID
	 )
	VALUES
	 (
	  @User_ID,
	  @Header_ID
	)
END
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_AddtoConcierge] TO ExecuteOnlyRole

GO
