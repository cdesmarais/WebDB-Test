if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_List]
GO

CREATE Procedure dbo.Admin_Offer_List
 (
  @Offer_ID int = 0
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @Offer_ID = 0
  Begin
    SELECT		offerID AS OfferID
				,Offer as Value 
	FROM		OfferVW
	order by	Offer
  End
if @Offer_ID <> 0
  Begin
    SELECT		Offer as Value 
    FROM		OfferVW 
    where		offerID = @Offer_ID
	order by	Offer
  End
GO

GRANT EXECUTE ON [Admin_Offer_List] TO ExecuteOnlyRole

GO
