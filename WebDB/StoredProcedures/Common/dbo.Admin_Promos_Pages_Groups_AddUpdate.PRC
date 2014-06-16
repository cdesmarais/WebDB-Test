



/*Procedure to check if the record Exists for the mapping of the Promo Group to promo Page. 
  If record Exists, Update the Records, else insert the record
*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_Groups_AddUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_Promos_Pages_Groups_AddUpdate]
go

create procedure dbo.Admin_Promos_Pages_Groups_AddUpdate
(
	@iPromoID				int
	,@iPromoGroupTypeID		int
	,@iPromoGroupTypeStatus	bit
	,@iExecutionStatus		bit out
)
as

	set @iExecutionStatus = 1
	
	/*Check if the Entry Exists for the @iPromoID*/
	if exists(select * from PromoPagesToPromoGroups where PromoID = @iPromoID and PromoGroupTypeID = @iPromoGroupTypeID)
	begin
	
		update PromoPagesToPromoGroups
		set		
			Active = @iPromoGroupTypeStatus
		where 
			PromoID = @iPromoID and 
			PromoGroupTypeID = @iPromoGroupTypeID
			
		if @@ERROR <> 0
			set @iExecutionStatus = 0
	end	
	else
	begin
		insert into PromoPagesToPromoGroups
		(
			PromoID
			,PromoGroupTypeID
			,Active
		)
		values
		(
			@iPromoID
			,@iPromoGroupTypeID
			,@iPromoGroupTypeStatus
		)
		
		if @@ERROR <> 0
			set @iExecutionStatus = 0
	end
go

grant execute on [Admin_Promos_Pages_Groups_AddUpdate] to ExecuteOnlyRole

go
