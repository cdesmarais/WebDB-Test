
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateRestaurateurs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateRestaurateurs]
GO

create procedure dbo.UpdateRestaurateurs
(
	@NoOfRestaurants nvarchar (500)
	,@NoOfDiners nvarchar(500)
	,@NoOfMonthlyDiners nvarchar(500)
	,@NoOfRestPartners nvarchar(500)
)
as
	-- This SP is used to update Number of restarunt and diners in valuelookup table
	
	-- Update Number of restaurnats
	update 
		ValueLookup 
	set 
		ValueChar = @NoOfRestaurants 
	where 
		LType = 'Webserver'  
		and LKey = 'Restaurants'

	-- Update Number of accumulated diners
	update 
		ValueLookup 
	set 
		ValueChar = @NoOfDiners 
	where 
		LType  = 'Webserver'  
		and LKey = 'Diners'

	-- Update Number of montly diners
	update 
		ValueLookup 
	set 
		ValueChar = @NoOfMonthlyDiners 
	where 
		LType  = 'Webserver'  
		and LKey = 'MonthlyDiners'
	
	-- Update Number of restaurant partners
	update 
		ValueLookup 
	set 
		ValueChar = @NoOfRestPartners
	where 
		LType  = 'Webserver'  
	and LKey = 'RestaurantPartner'

	
GO


GRANT EXECUTE ON [UpdateRestaurateurs] TO ExecuteOnlyRole

GO


