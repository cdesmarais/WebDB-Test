if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_printLogInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_printLogInfo]
GO

CREATE PROCEDURE dbo.XML_printLogInfo
(@tranID int
)

 AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @req nvarchar(1000),@res nvarchar(1000)

select @req = XMLRequest,@res = XMLResponse from XMLLogTransaction
where TransactionID = @tranID
print @req
print @res

GO

GRANT EXECUTE ON [XML_printLogInfo] TO ExecuteOnlyRole

GO
