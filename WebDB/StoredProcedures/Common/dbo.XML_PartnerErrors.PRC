if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_PartnerErrors]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_PartnerErrors]
GO

CREATE PROCEDURE dbo.XML_PartnerErrors
(
@PartnerID int
)
 AS
--SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select ErrorDate as error_date
	,PartnerID as partner_id
	,RemoteIP as remote_ip
	,ErrorDescription as error_description
	,ErrorNumber as error_number
	,TransactionType as transaction_type
	,XMLRequesttype as xml_requesttype
from XMLLogError 
where PartnerID = @PartnerID
order by ErrorDate desc
GO

GRANT EXECUTE ON [XML_PartnerErrors] TO ExecuteOnlyRole

GO
