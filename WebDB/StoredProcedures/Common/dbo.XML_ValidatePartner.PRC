if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_ValidatePartner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_ValidatePartner]
GO

CREATE PROCEDURE dbo.XML_ValidatePartner
(
  @PartnerID int,
  @RequestIP nvarchar(30)
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @count int

select @count = count(PartnerIPs.PartnerID) from PartnerIPs inner join Partner on PartnerIPs.PartnerID = Partner.PartnerID
			where PartnerIPs.PartnerID = @PartnerID And IPAddress = @RequestIP and XMLFlag = 1
if @count <> 1
	    RAISERROR ('94',16,1)
GO


GRANT EXECUTE ON [XML_ValidatePartner] TO ExecuteOnlyRole

GO
