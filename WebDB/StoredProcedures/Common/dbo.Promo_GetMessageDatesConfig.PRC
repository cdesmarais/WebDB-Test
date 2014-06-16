

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetMessageDatesConfig]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetMessageDatesConfig]
go

create procedure [dbo].[Promo_GetMessageDatesConfig]
(
	@Domain_ID int
	,@PromoID int
)
as
begin
	/*
		This procedure gets the promo configuration related to a single promo.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	select 
		pp.PromoID 
		,pp.PromoPageName
		,pp.EventStartDate as PromoStartDTPST
		,pp.EventEndDate as PromoEndDTPST
		,pmdc.ScriptStartDTPST
		,pmdc.ScriptEndDTPST
		,pmdc.DateSpecificMsgDTPST
	from
 		PromoMsgExTool_DatesConfig pmdc
	right outer join
		PromoPages pp
 		on pmdc.PromoID = pp.PromoID
	where
 		pp.SupportedDomainID = @Domain_ID
	and
		pp.PromoID = @PromoID

end

go

grant execute on [Promo_GetMessageDatesConfig] to ExecuteOnlyRole

go

