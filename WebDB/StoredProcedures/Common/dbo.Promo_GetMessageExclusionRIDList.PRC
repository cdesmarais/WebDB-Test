

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetMessageExclusionRIDList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetMessageExclusionRIDList]
go

create procedure [dbo].[Promo_GetMessageExclusionRIDList]
(	
	@PromoID int
)
as
begin
	/*
		This procedure gets the list of restaurants that are to be excluded from promo messages.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	
	select
		r.RID
		,r.RName
		,m.MetroAreaName
		,pmre.OptedOutDTPST
		,pmre.OptedOutBy
	from 
		PromoMsgExTool_RIDExclusion pmre
	inner join
		PromoMsgExTool_DatesConfig pmdc
		on pmre.PromoMsgID = pmdc.PromoMsgID
	inner join
		PromoPages p
		on p.PromoID = pmdc.PromoID
	inner join
		RestaurantAVw r
		on pmre.RID = r.RID
		and p.LanguageID = r.LanguageID
	inner join NeighborhoodAVW n
		on r.NeighborhoodID = n.NeighborhoodID
		and p.LanguageID = n.LanguageID
	inner join MetroAreaAVW m
		on n.MetroAreaID = m.MetroAreaID
		and p.LanguageID = m.LanguageID
	where
		pmdc.PromoID = @PromoID
	order by
		r.RID

end

go

grant execute on [Promo_GetMessageExclusionRIDList] to ExecuteOnlyRole

go

