

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OSCAR_MarkRestaurantInactiveNDuplicate1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OSCAR_MarkRestaurantInactiveNDuplicate1]
go

create procedure [dbo].[OSCAR_MarkRestaurantInactiveNDuplicate1]
(
	@DeletedSDFDCID varchar(18),
	@SurvivingSDFDCID varchar(18),
	@SurvivingRID int
)  

as
begin
	
	declare @DeletedRID int
	
	select
			@DeletedRID = RID
	from
			Restaurant
	where
			RestaurantSFDCID = @DeletedSDFDCID
			
	if (isnull(@DeletedRID,-1) <> @SurvivingRID)
	begin
		update
				Restaurant
		set 
				Duplicate = 1 
				,RestStateID = 4
				,RestaurantSFDCID = null
		where 
				RID = @DeletedRID
	end
	else
	begin
		update
				Restaurant
		set 
				Duplicate = 1 
				,RestStateID = 4
				,RestaurantSFDCID = null
		where 
				RestaurantSFDCID = @SurvivingSDFDCID
						
		update
				Restaurant
		set
				Duplicate = 0
				,RestaurantSFDCID = @SurvivingSDFDCID
		where
				RID = @SurvivingRID
	end		

end
go

grant execute on [OSCAR_MarkRestaurantInactiveNDuplicate1] to ExecuteOnlyRole

go
