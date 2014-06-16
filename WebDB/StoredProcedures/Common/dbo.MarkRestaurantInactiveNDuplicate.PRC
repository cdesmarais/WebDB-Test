

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MarkRestaurantInactiveNDuplicate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MarkRestaurantInactiveNDuplicate]
go

create procedure [dbo].[MarkRestaurantInactiveNDuplicate]
(
	@AccountSDFDCID varchar(20)
)  

as
begin
	
	update
			Restaurant
	set 
			Duplicate = 1 
			, RestStateID = 4
			, RestaurantSFDCID = null
	where 
			RestaurantSFDCID = @AccountSDFDCID

end
go

grant execute on [MarkRestaurantInactiveNDuplicate] to ExecuteOnlyRole

go
