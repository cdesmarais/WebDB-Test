if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Review]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Review]
GO
  
CREATE PROCEDURE dbo.Admin_Restaurant_Review  
	@RestaurantID int,  
	@PartnerID int,  
	@ProviderID int=0, 
	@ContentID int=0
AS  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
if (@ProviderID = 0)  
  begin
	-- This part of procedure use to get the  review information from content table as per the 
	-- RestaurantID and Provider ID, The selected record is sorted as per the Provder name and then
	-- with the state of review (active/suppress) 
	SELECT 
		 Content.ContentID as ContentID
		,Content.ProviderID as Provider_ID
		,Provider.ProviderName As provname
		,Content.Enabled
		,Content.Content as Value
		,Content.ShortValue
		,Provider.LogoName as Logo_Name
		,Content.ContentID as Content_ID  
	FROM Content   
	INNER JOIN Provider   
	ON Content.ProviderID = Provider.ProviderID  
	WHERE Content.RID = @RestaurantID   
		and Provider.ProviderID in   
		(Select ProviderID 
		 from ContentPartner2ProviderRelationships 
		 where PartnerID = @PartnerID)  
	ORDER BY Provider.ProviderName, Content.Enabled DESC
  end 
  
if (@ProviderID > 0)  
  begin
	-- This part of procedure is use to get the review information from content table as per the
    -- RestaurantID,ProviderID and ContentID to update particular review.
	SELECT 
		Content.ContentID as ContentID
		,Content.ProviderID as Provider_ID
		,Provider.ProviderName As provname
		,Content.Enabled
		,Content.Content as Value
		,Content.ShortValue
		,Provider.LogoName as Logo_Name
		,Content.ContentID as Content_ID  
	FROM Content   
	INNER JOIN Provider   
	ON Content.ProviderID = Provider.ProviderID  
	WHERE Content.RID = @RestaurantID   
		and Provider.ProviderID in   
		(Select ProviderID 
		 from ContentPartner2ProviderRelationships 
		 where PartnerID = @PartnerID 
			   And ProviderID = @ProviderID) 
		and Content.ContentID = @ContentID 
	ORDER BY Provider.ProviderName, Content.Enabled DESC 
  end
  
GO

GRANT EXECUTE ON [Admin_Restaurant_Review] TO ExecuteOnlyRole

GO

