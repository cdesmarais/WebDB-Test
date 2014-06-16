
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SearchWebPagePromosByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SearchWebPagePromosByName]
GO

create procedure dbo.[SearchWebPagePromosByName]
(
	@PromoName varchar(65)
)
AS

-- This proc is used to search  Promos by given PromoName

select	
	PromoID
	,PromoPageName as PromoName
from	 
	PromoPages

where	 
	PromoPageName like '%'+@PromoName+'%'
escape '\'
order by 
	PromoPageName 


GO


GRANT EXECUTE ON [SearchWebPagePromosByName] TO ExecuteOnlyRole

GO

