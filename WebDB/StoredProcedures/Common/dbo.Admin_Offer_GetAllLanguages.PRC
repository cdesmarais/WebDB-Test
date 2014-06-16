if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_GetAllLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_GetAllLanguages]
GO

CREATE Procedure dbo.Admin_Offer_GetAllLanguages
 (
  @Offer_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	o.Offer as Offer, 
	l.languageID as LanguageID,
	l.LanguageRegionDesc as LanguageName
FROM	OfferAVW o
INNER JOIN Language l
on o.languageID = l.LanguageID
where	offerID = @Offer_ID

GO

GRANT EXECUTE ON [Admin_Offer_GetAllLanguages] TO ExecuteOnlyRole

GO
