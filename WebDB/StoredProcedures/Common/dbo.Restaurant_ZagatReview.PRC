if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ZagatReview]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ZagatReview]
GO

CREATE PROCEDURE dbo.Restaurant_ZagatReview 
@RestaurantID int,
@PartnerID int
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @check int
Select @check=5
if Exists(Select 1 From Content Where RID=@RestaurantID And ProviderID=1)
   Begin
   Select @check = (Select count(Content.ContentTypeID) From Content Inner Join ContentType On Content.ContentTypeID=ContentType.ContentTypeID
                              Inner Join Content_Value On Content.Content_ID=Content_Value.Content_ID
                              Where Content.ContentTypeID IN(1,2,3,4,7) And Enabled=1 And RID=@RestaurantID)
   End
if (@check <> 5) Goto zagat_error

SELECT Content.ContentTypeID as Content_Type_ID,Content.ProviderID as Provider_ID,
	Provider.ProviderName as Name,Provider.LogoName as Logo_Name,
        Content.ContentID as Content_ID,Content.Content as Value
,Content.ShortValue
,retval=0
FROM Content 
INNER JOIN ContentType 
ON Content.ContentTypeID = ContentType.ContentTypeID 
INNER JOIN Provider 
ON Content.ProviderID = Provider.ProviderID
WHERE RID = @RestaurantID and Provider.ProviderID in 
    (Select ProviderID from ContentPartner2ProviderRelationships where Enabled = 1 and PartnerID = @PartnerID And ProviderID=1) and Content.Enabled = 1
ORDER BY Provider.ProviderID
RETURN(0)

zagat_error:
    RAISERROR ('57',1,2)
    Select retval = 1
    RETURN(1)
GO

GRANT EXECUTE ON [Restaurant_ZagatReview] TO ExecuteOnlyRole

GO
