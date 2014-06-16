

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_MessageOptInOptOutRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_MessageOptInOptOutRID]
go

create procedure [dbo].[Promo_MessageOptInOptOutRID]
(	
	@PromoID int	
	,@RID int
	,@IsOptOut bit
	,@OptedOutBy varchar(200) = null	
)
as
begin
	/*
		This procedure inserts the RID against a Promo indicating that the restaurant does not want same promo message in the date specific message.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	declare @PromoMsgID int
	-- Get the Promo Message ID
	select
		@PromoMsgID = PromoMsgID
	from
		PromoMsgExTool_DatesConfig
	where
		PromoID = @PromoID

	if (@IsOptOut = 1)
		begin
		
			insert into
				PromoMsgExTool_RIDExclusion
				(
					PromoMsgID
					,RID
					,OptedOutBy
					,OptedOutDTPST
				)
				values
				(
					@PromoMsgID
					,@RID
					,@OptedOutBy
					,getdate()
				)
		end
	else
		begin
			delete from
				PromoMsgExTool_RIDExclusion
			where	
				PromoMsgID = @PromoMsgID
			and
				RID = @RID
		end
end

go

grant execute on [Promo_MessageOptInOptOutRID] to ExecuteOnlyRole

go

