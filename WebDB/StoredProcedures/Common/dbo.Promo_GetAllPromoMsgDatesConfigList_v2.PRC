

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetAllPromoMsgDatesConfigList_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetAllPromoMsgDatesConfigList_v2]
go

create procedure [dbo].[Promo_GetAllPromoMsgDatesConfigList_v2]

as
begin
	/*
		This procedure gets list of promo messages configured for execution.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	select 
		pmdc.PromoMsgID
		,pp.PromoID 
		,pp.PromoPageName
		,pmdc.ScriptStartDTPST
		,pmdc.ScriptEndDTPST
	from
 		PromoMsgExTool_DatesConfig pmdc
	inner join 
		PromoPages pp
 		on pmdc.PromoID = pp.PromoID
	order by 
		pmdc.ScriptStartDTPST desc

end

go

grant execute on [Promo_GetAllPromoMsgDatesConfigList_v2] to ExecuteOnlyRole

go

