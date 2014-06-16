if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetPartnersByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetPartnersByID]
GO




CREATE PROCEDURE dbo.Admin_GetPartnersByID
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select PartnerID as partner_ID,PartnerName as Name
From Partner
Where XMLFlag = 1
Order By PartnerName
GO

GRANT EXECUTE ON [Admin_GetPartnersByID] TO ExecuteOnlyRole

GO
