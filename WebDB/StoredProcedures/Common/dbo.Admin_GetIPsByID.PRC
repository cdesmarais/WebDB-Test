if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetIPsByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetIPsByID]
GO




CREATE PROCEDURE dbo.Admin_GetIPsByID
(
    @partnerID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select PartnerName as Name,IPAddress as IP_Address,Partner.PartnerID as Partner_ID
From Partner inner join PartnerIPs on Partner.PartnerID = PartnerIPs.PartnerID
where Partner.PartnerID = @partnerID And XMLFlag = 1
GO

GRANT EXECUTE ON [Admin_GetIPsByID] TO ExecuteOnlyRole

GO
