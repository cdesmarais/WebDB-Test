if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserRemoveFavorite]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserRemoveFavorite]
go

create Procedure dbo.DNUserRemoveFavorite
 (
  @UserID int,  
  @RID int,
  @IsCaller int = 0  --this param indicates if @UserID is a user_id or a caller_id
 )
As
set nocount on

begin transaction

declare @i int

begin
	if @IsCaller = 0
		begin
			Update		Customer 
			set			UpdatedFavorites = 1 
			where		CustID = @UserID
			
			if (@@error > 0)
				goto general_error

			--*******************
			--Remove the RID
			--*******************
  			delete		Favorites 
			from		Favorites c  		
  			where		CustID =  @UserID
  			and			RID = @RID

			if (@@error > 0)
				goto general_error
				  			
		end
	else if @IsCaller > 0
		begin
			Update		Caller 
			set			UpdatedFavorites = 1 
			where		CallerID = @UserID

			if (@@error > 0)
				goto general_error
			
			--*******************
			--Remove the RIDs that are no longer in the rid set
			--*******************
  			delete		CallerRestaurants 
			from		CallerRestaurants c
  			where		CallerID =  @UserID
  			and			RID = @RID

			if (@@error > 0)
				goto general_error
		end
end

commit transaction
Return(0)

general_error:
	rollback transaction
	raiserror('Unable to remove favorite',16,1)
go

grant execute on [DNUserRemoveFavorite] TO ExecuteOnlyRole

go
