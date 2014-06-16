if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_SetPartnerIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_SetPartnerIP]
GO

CREATE PROCEDURE dbo.XML_SetPartnerIP
(
@PartnerID int
,@IP nvarchar(30)
)

 AS

SET NOCOUNT ON

insert into PartnerIPs (IPAddress,PartnerID)
values (@IP,@PartnerID)

GO

GRANT EXECUTE ON [XML_SetPartnerIP] TO ExecuteOnlyRole

GO
