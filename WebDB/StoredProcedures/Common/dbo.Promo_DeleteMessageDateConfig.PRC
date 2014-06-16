

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_DeleteMessageDateConfig]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_DeleteMessageDateConfig]
GO

create procedure [dbo].[Promo_DeleteMessageDateConfig]
(
	@PromoMsgId int
)
as

	/*
		This procedure deletes the promo message configurion.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/
begin transaction
	
	delete from 
		PromoMsgExTool_RIDExclusion
	where
		PromoMsgID = @PromoMsgId
	
	if @@error <> 0
		goto error

	delete
		PromoMsgExTool_DatesConfig
	where
		PromoMsgID = @PromoMsgId
	
	if @@error <> 0
		goto error

	commit transaction

	error:  
		rollback transaction

GO

grant execute on [dbo].[Promo_DeleteMessageDateConfig] TO ExecuteOnlyRole

GO

