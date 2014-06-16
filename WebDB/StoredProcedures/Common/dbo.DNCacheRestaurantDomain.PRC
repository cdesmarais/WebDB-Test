if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantDomain]
GO

--
-- Retrieves the contents of the RestaurantDomain table for mapping RIDs onto their proper domain
-- TT 22481 mmc

CREATE Procedure dbo.DNCacheRestaurantDomain
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT	rd.RID,
		rd.DomainID,
		d.Domain,
		d.PublicSite,
		rd.NewRID,
		rd.EffectiveDate
FROM	RestaurantDomain rd
	INNER JOIN Domain d ON rd.domainID = d.domainID
GO

GRANT EXECUTE ON [DNCacheRestaurantDomain] TO ExecuteOnlyRole

GO

