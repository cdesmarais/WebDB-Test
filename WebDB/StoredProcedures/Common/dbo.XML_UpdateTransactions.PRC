if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_UpdateTransactions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_UpdateTransactions]
GO

CREATE PROCEDURE dbo.XML_UpdateTransactions
(
  @TransID int,
  @XMLResponse nvarchar(1000)
)
AS

Update XMLLogTransaction
Set XMLResponse = @XMLResponse
Where TransactionID=@TransID

GO


GRANT EXECUTE ON [XML_UpdateTransactions] TO ExecuteOnlyRole

GO
