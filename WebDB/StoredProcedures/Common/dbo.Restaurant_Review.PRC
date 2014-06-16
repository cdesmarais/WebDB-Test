if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Review]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Review]
GO

CREATE PROCEDURE dbo.Restaurant_Review
@RestaurantID int,
@PartnerID int,
@ProviderID int=0
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if (@ProviderID = 0)
    SELECT Content.ContentTypeID as Content_Type_ID,
			Content.ProviderID as Provider_ID,
			Provider.ProviderName as Name,
			Provider.LogoName as Logo_Name,
        Content.ContentID as Content_ID,
	Case when(Content.providerid in (3,5)) then '' else Content.Content end as Value,
        Content.ShortValue as ShortValue,
        metroareaid as Metro_Area_ID
    FROM Content 
    INNER JOIN ContentType ON Content.ContentTypeID = ContentType.ContentTypeID 
    INNER JOIN Provider ON Content.ProviderID = Provider.ProviderID
    WHERE RID = @RestaurantID and Provider.ProviderID in 
        (Select ProviderID from ContentPartner2ProviderRelationships where Enabled = 1 and PartnerID = @PartnerID) and Content.Enabled = 1
    ORDER BY metroareaid,Provider.ProviderName
if (@ProviderID > 0)
    SELECT Content.ContentTypeID as Content_Type_ID,
		Content.ProviderID as Provider_ID,
		Provider.ProviderName as Name,
		Provider.LogoName as Logo_Name,
        Content.ContentID as Content_ID,
        Content.Content as Value,
        Content.ShortValue as ShortValue
    FROM Content 
    INNER JOIN
        ContentType ON 
        Content.ContentTypeID = ContentType.ContentTypeID 
    INNER JOIN
        Provider ON Content.ProviderID = Provider.ProviderID
    WHERE RID = @RestaurantID and Provider.ProviderID in 
        (Select ProviderID from ContentPartner2ProviderRelationships where Enabled = 1 and PartnerID = @PartnerID And ProviderID = @ProviderID) and Content.Enabled = 1
    ORDER BY Provider.ProviderID
GO

GRANT EXECUTE ON [Restaurant_Review] TO ExecuteOnlyRole

GO
