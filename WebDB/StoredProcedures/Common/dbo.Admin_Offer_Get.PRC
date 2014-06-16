if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_Get]
GO

CREATE Procedure dbo.Admin_Offer_Get
 (
  @Offer_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	Offer
FROM	OfferVW
where	offerID = @Offer_ID

GO

GRANT EXECUTE ON [Admin_Offer_Get] TO ExecuteOnlyRole

GO
