

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SearchWebPagePromosByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SearchWebPagePromosByID]
GO

create procedure dbo.[SearchWebPagePromosByID]
(
	@PromoID int
)
AS

--This Proc is used to Search Promos by given ID.

select	
	PromoID
	,PromoPageName as PromoName
from	 
	PromoPages

where	 
	PromoID = @PromoID

GO


GRANT EXECUTE ON [SearchWebPagePromosByID] TO ExecuteOnlyRole

GO



