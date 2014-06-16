if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserAddFavorite]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserAddFavorite]
go

create Procedure dbo.DNUserAddFavorite
 (
  @UserID int,  
  @RID int,
  @IsCaller int = 0  --this param indicates if @UserID is a user_id or a caller_id
 )
As
set nocount on

begin transaction

	begin
		if @IsCaller = 0 and 
			not exists (
				select		1 
				from		Favorites 
				where		CustID = @UserID 
				and			RID = @RID
			)
			begin
				update		Customer 
				set			UpdatedFavorites = 1 
				where		CustID = @UserID

				if (@@ERROR <> 0)
					goto general_error

				--*******************
				-- Add a RID to favorites
				--*******************
				
				insert into	Favorites
							(CustID,RID)
				values		(@UserID, @RID)
					  			
				if (@@ERROR <> 0)
					goto general_error

			end
		else if @IsCaller > 0 and 
			not exists (
				select		1 
				from		dbo.CallerRestaurants
				where		CallerID = @UserID 
				and			RID = @RID
			)
			begin
				update		Caller 
				set			UpdatedFavorites = 1 
				where		CallerID = @UserID
				
				if (@@ERROR <> 0)
					goto general_error

				--*******************
				-- Add a RID to callerrestaurants
				--*******************
				insert into	CallerRestaurants
							(CallerID,RID)
				values		(@UserID,@RID)

				if (@@ERROR <> 0)
					goto general_error

			end
	end

commit transaction
return(0)

general_error:
	rollback transaction
	raiserror('Unable to add to user favorites',16,1)
go

grant execute on [DNUserAddFavorite] TO ExecuteOnlyRole

go
