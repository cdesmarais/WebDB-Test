if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetOfferTypeAttributeLookups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetOfferTypeAttributeLookups]
GO

--gets the dropdown values for an offer attriubte type
CREATE PROCEDURE dbo.GetOfferTypeAttributeLookups

@offertypeattributeKeyID int

AS

SELECT ov.[Rank]
      ,ov.[KeyLookup]
      ,ov.[KeyLookupID]
      ,ov.[LanguageID]
      ,ov.[OfferTypeAttributeKeyID]
FROM   offertypeattributekeylookupvw ov 
       INNER JOIN offertypeattributekey o 
         ON o.offertypeattributekeyid = ov.offertypeattributekeyid 
WHERE  ov.offertypeattributekeyid = @offertypeattributeKeyID 
ORDER BY ov.rank

GO

GRANT EXECUTE ON [GetOfferTypeAttributeLookups] TO ExecuteOnlyRole

GO