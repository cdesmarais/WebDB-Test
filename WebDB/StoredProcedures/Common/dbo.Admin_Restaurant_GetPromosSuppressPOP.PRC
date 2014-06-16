if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetPromosSuppressPOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetPromosSuppressPOP]
GO

create procedure [dbo].[Admin_Restaurant_GetPromosSuppressPOP]
(
	 @rid	int 
	,@date  datetime = null 
)
as
	set transaction isolation level read uncommitted
	set nocount on
	
	set @date = ISNULL(@date,getdate())

	select pp.PromoID, pp.PromoPageName 
	from RestaurantVW r
	inner  join PromoRests pr
	on r.RID = pr.RID
	inner join PromoPages pp
	on pr.PromoID = pp.PromoID  and pp.active =1  and (@date between pp.EventStartDate and pp.EventEndDate)
	left join PromoDIPSupressExclusion pds
	on pp.PromoID = pds.PromoID and r.RID = pds.RID
	where r.RID = @rid and (ISNULL(pds.SupressDIPLunch, pp.SuppressDIP) = 1 OR ISNULL(pds.SupressDIPDinner, pp.SuppressDIP) = 1)
	order by pp.PromoPageName
GO

GRANT EXECUTE ON [Admin_Restaurant_GetPromosSuppressPOP] TO ExecuteOnlyRole
GO