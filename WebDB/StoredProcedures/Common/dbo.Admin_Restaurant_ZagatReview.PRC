if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ZagatReview]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ZagatReview]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_ZagatReview 
@RestaurantID int,
@PartnerID int
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Declare @check int
Select @check=5if Exists(Select 1 From Content Where RID=@RestaurantID And ProviderID=1)
   Begin
   Select @check = (Select count(Content.ContentTypeID) From Content 
		    Inner Join ContentType On Content.ContentTypeID=Content.ContentTypeID
                              Where Content.ContentTypeID IN(1,2,3,4,7) And RID=@RestaurantID)
   End
if (@check <> 5) Goto zagat_error

SELECT Content.ContentTypeID as Content_Type_ID,Content.Enabled,Content.ContentID as Content_ID,Content.Content,
	Content.ShortValue,Provider.LogoName as Logo_Name,retval=0
FROM Content 
INNER JOIN
        Provider ON Content.ProviderID = Provider.ProviderID
WHERE RID = @RestaurantID and Provider.ProviderID in 
    (Select ProviderID from ContentPartner2ProviderRelationships where PartnerID = @PartnerID And ProviderID=1)
RETURN(0)

zagat_error:
    RAISERROR ('57',1,2)
    Select retval = 1
    RETURN(1)
GO

GRANT EXECUTE ON [Admin_Restaurant_ZagatReview] TO ExecuteOnlyRole

GO
