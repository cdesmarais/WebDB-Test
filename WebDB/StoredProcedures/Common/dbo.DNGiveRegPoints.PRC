
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGiveRegPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGiveRegPoints]
GO




CREATE PROCEDURE dbo.DNGiveRegPoints(@CustID integer, @CallerID integer)
 AS

	declare @Points integer
	declare @RegPromoId integer

	-- Registration Promo Id
	set @RegPromoId = 1
	
	-- ** Retrieve the Promo Points associated with registration
	select @Points = points from Promos
	where promoId = @RegPromoId

		Insert into PromoUse (CustID, CallerID, PromoID, Points, RedeemDate, SiteID)
		VALUES
		(@CustID,
		 @CallerID, 
		 @RegPromoId,  -- PromoID
		 @Points, -- Points
		 current_timestamp,
		 1)
 


GO


GRANT EXECUTE ON [DNGiveRegPoints] TO ExecuteOnlyRole

GO
