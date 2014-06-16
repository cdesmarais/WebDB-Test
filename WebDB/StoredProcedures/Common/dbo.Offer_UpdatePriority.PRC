


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_UpdatePriority]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_UpdatePriority]
go

--
-- Updates an Offer Priority.  
-- 

create Procedure dbo.Offer_UpdatePriority
(	
	@OfferId int
	,@NewPriority int
)	
as
	
	declare @DBError int  
   
	declare @CurrentPriority int  
	declare @RID int  
	
  
	/* Get Restaurant Id and current Priority of the Offer */  
	select  
		@RID = rid  
		,@CurrentPriority = Priority  
	from   
		RestaurantOffer  
	where  
		RestaurantOfferId = @OfferId    
   	
   
	/* Early exit... */  
	if(@CurrentPriority is null and @NewPriority is null)  
		return 1   
  
	if(@CurrentPriority = @NewPriority)  
		return 1  
  
   
	begin transaction  

	if (@NewPriority > @CurrentPriority)  
	begin  
		update  
			RestaurantOffer  
		set  
			Priority = Priority -1  
		where
			RID = @RID  
			and Priority > @CurrentPriority  
			and Priority <= @NewPriority  
			and coalesce(Priority,0) > 1  			
     
		set @DBError = @@error  
		if @DBError <> 0  
			goto general_error     
		end  
	else if(@NewPriority < @CurrentPriority)  
	begin  
		update  
			RestaurantOffer  
		set  
			Priority = Priority + 1  
		where 
			RID = @RID 
			and Priority < @CurrentPriority  			
			and coalesce(Priority,0) >= @NewPriority  
			

		set @DBError = @@error  
		if @DBError <> 0  
			goto general_error  
	end  
   
   	update  
		RestaurantOffer  
	set  
		Priority = @NewPriority  
	where  
		RestaurantOfferId = @OfferId  
  
	set @DBError = @@error  
	if @DBError <> 0  
		goto general_error  
  
	commit transaction  
	return(0)  
  
	general_error:  
		rollback transaction   
		return(-1)  

go

grant execute on [Offer_UpdatePriority] TO ExecuteOnlyRole

go



