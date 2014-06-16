if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_showTransactionInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_showTransactionInfo]
GO

CREATE PROCEDURE dbo.XML_showTransactionInfo
(
@TranID int
)
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @date datetime,@head nvarchar(1000),@req nvarchar(1000),@resp nvarchar(1000),@strDate nvarchar(30)
	select @date = TransactionDate,@head = RequestHeader, @req = XMLRequest,@resp = XMLResponse
	from XMLLogTransaction where TransactionID = @TranID
  	/*set @head = (select top 1 RequestHeader from XML_logtransaction
   	where
   	RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID)
   	order by TransactionDate desc)
	set @req = (select top 1 XMLRequest from XML_logtransaction
   	where
   	RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID)
   	order by TransactionDate desc)
	set @resp = (select top 1 XMLResponse from XML_logtransaction
   	where
   	RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID)
   	order by TransactionDate desc)*/
set @strDate =  getDate()
print 'current server time: '  + @strDate
print 'latest Partner transaction information:'
print @date
print @head
print @req   
print @resp

GO


GRANT EXECUTE ON [XML_showTransactionInfo] TO ExecuteOnlyRole

GO
