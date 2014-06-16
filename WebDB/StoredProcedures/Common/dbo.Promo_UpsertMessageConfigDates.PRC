

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_UpsertMessageConfigDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_UpsertMessageConfigDates]
go

create procedure [dbo].[Promo_UpsertMessageConfigDates]
(	
	@PromoID int
	,@ScriptStartDTPST datetime
	,@ScriptEndDTPST datetime
	,@DateSpMsgDTPST datetime
)
as
begin
	/*
		This procedure updates the dates for an exisitng promo. Creates the promo configuration is not existing.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	if exists (
			select
				1
			from
				PromoMsgExTool_DatesConfig
			where
				PromoID = @PromoID							
			)
		begin
			update
				PromoMsgExTool_DatesConfig
			set
				ScriptStartDTPST = @ScriptStartDTPST
				,ScriptEndDTPST = @ScriptEndDTPST
				,DateSpecificMsgDTPST = @DateSpMsgDTPST
			where
				PromoID = @PromoID
		end
	else
		begin
			insert into
				PromoMsgExTool_DatesConfig
				(
					PromoID
					,ScriptStartDTPST
					,ScriptEndDTPST
					,DateSpecificMsgDTPST
				)
				values
				(
					@PromoID
					,@ScriptStartDTPST
					,@ScriptEndDTPST
					,@DateSpMsgDTPST
				)
		end

end

go

grant execute on [Promo_UpsertMessageConfigDates] to ExecuteOnlyRole

go

