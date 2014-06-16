if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetOfferTypeAttributesAndValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetOfferTypeAttributesAndValues]
GO

--gets the attributes for an offer type and the attribute values (if a 
--restaurantOfferID is supplied)
CREATE PROCEDURE dbo.GetOfferTypeAttributesAndValues

@restaurantOfferTypeID int,
@restaurantOfferID int = -1

AS

SELECT ov.[KeyName]
      ,ov.[LanguageID]
      ,ov.[OfferTypeAttributeKeyID]
       ,otav.valuetext
       ,otav.valueint 
FROM   offertypeattributekeyvw ov 
       INNER JOIN offertypeattributekeymap o 
         ON o.offertypeattributekeyid = ov.offertypeattributekeyid 
       LEFT JOIN offertypeattributevalue otav 
         ON otav.offertypeattributekeyid = ov.offertypeattributekeyid 
WHERE  o.restaurantoffertypeid = @restaurantOfferTypeID 
       AND ( ( otav.restaurantofferid IS NULL ) 
              OR ( otav.restaurantofferid = @restaurantOfferID ) ) 
							
GO

GRANT EXECUTE ON [GetOfferTypeAttributesAndValues] TO ExecuteOnlyRole

GO