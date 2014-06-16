if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetProviders]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetProviders]
GO
    
CREATE PROCEDURE dbo.Admin_GetProviders
(
	@Restaurant_ID int  
)  
As  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

-- select the provider information from the provider table,
-- Provider are select as per the following rule:
-- 1. The which have no reviews in content table.
-- 2. The provider who have review in content table but not in active state.
-- Checking Enabled=1 in where clause for following reason:
-- 1.To avoid the selection of provider who already have active review in content table.
-- 2.To avoid user to add more review for provider if already one in active state for same provider.  

Select 
	ProviderID as provider_id
	,ProviderName as name
	,LogoName as logo_name
	,ContentTypeID as content_type_id
	,metroareaid as metro_area_ID  
from Provider    
where ProviderID Not In(Select ProviderID 
						From Content cnt
						Where cnt.RID=@Restaurant_ID 
							  AND cnt.Enabled=1)  

GO

GRANT EXECUTE ON [Admin_GetProviders] TO ExecuteOnlyRole

GO

