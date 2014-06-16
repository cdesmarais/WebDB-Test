if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_LogTransactions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_LogTransactions]
GO

CREATE PROCEDURE dbo.XML_LogTransactions
(
  @TransType int
  ,@XMLRequest nvarchar(1000)
  ,@XMLResponse nvarchar(1000)=Null
  ,@RemoteIP nvarchar(30)
  ,@ssl bit
  ,@RequestHeader nvarchar(1000) = ''
 )
AS

Insert Into XMLLogTransaction(transactiontype,XMLRequest,XMLResponse,RemoteIP,ssl,RequestHeader)
Values(@TransType,@XMLRequest,@XMLResponse,@RemoteIP,@ssl,@RequestHeader)

GO

GRANT EXECUTE ON [XML_LogTransactions] TO ExecuteOnlyRole

GO
