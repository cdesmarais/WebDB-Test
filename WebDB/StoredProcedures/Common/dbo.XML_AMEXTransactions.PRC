if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_AMEXTransactions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_AMEXTransactions]
GO

CREATE PROCEDURE dbo.XML_AMEXTransactions

AS

set transaction isolation level read uncommitted

select TransactionDate as transaction_date
,XMLRequest as xml_request
,XMLResponse as xml_response
,RequestHeader as Request_header 
from  XMLLogTransaction 
where RemoteIP in (select IPAddress from PartnerIPs where PartnerID = 10)
order by TransactionDate desc

GO

GRANT EXECUTE ON [XML_AMEXTransactions] TO ExecuteOnlyRole

GO
