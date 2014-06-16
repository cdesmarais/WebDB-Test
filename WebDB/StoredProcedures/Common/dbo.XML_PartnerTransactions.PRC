if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_PartnerTransactions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_PartnerTransactions]
GO

CREATE PROCEDURE dbo.XML_PartnerTransactions

(
@PartnerID int
,@tranCount int = 10
)
 AS
 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @tranCount = 10 
     Begin
	select top 10 TransactionID as transaction_id
	,TransactionDate as transaction_date
	,XMLRequest as xml_request
	,XMLResponse as xml_response
	,RequestHeader as Request_header
	,ssl,RemoteIP as remote_ip 
	from  XMLLogTransaction 
	where 	RemoteIP in (select IPAddress from PartnerIPs where PartnerID = @PartnerID)
	order by TransactionDate desc
     End

Else
     BEGIN
	declare @sql nvarchar(500)
	set @sql = 'select top ' + Cast(@tranCount as nvarchar) + ' TransactionID as transaction_id,TransactionDate as transaction_date,XMLRequest as xml_request,XMLResponse as xml_response,RequestHeader as Request_header,ssl,RemoteIP as remote_ip from  XMLLogTransaction where
	RemoteIP in (select IPAddress from PartnerIPs where PartnerID = ' + Cast(@PartnerID as nvarchar) + ') order by TransactionDate desc'
	exec sp_executesql @stmt = @sql
     END
GO

GRANT EXECUTE ON [XML_PartnerTransactions] TO ExecuteOnlyRole

GO
