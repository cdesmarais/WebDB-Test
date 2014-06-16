if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_LogErrors]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_LogErrors]
GO

CREATE PROCEDURE dbo.XML_LogErrors
(
  @methodname nvarchar(100),
  @errstring nvarchar(1000),
  @ErrNum nvarchar(20),
  @remoteIP nvarchar(30),
  @transtype int,
  @PartnerID int
)
AS

Insert Into XMLLogError(XMLRequestType,ErrorDescription,ErrorNumber,RemoteIP,TransactionType,PartnerID)
Values(@methodname,@errstring,@ErrNum,@remoteIP,@transtype,@PartnerID)

GO

GRANT EXECUTE ON [XML_LogErrors] TO ExecuteOnlyRole

GO
