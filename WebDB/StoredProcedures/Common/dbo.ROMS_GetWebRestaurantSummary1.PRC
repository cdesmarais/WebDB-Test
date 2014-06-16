

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_GetWebRestaurantSummary1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ROMS_GetWebRestaurantSummary1]
go

/* 
	Stored procedure to get combined Restaurant Summary information of all restaurants belonging to different Regional WebDB's. 
	This stored procedure is used by PJR Job that transfers Restaurant Summary info from WebDB to GOD database. 
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

create procedure dbo.ROMS_GetWebRestaurantSummary1
as  

select 
	WebRID
	,MinOnlineOptionID
	,PartySizeMinimumValue
	,PartySizeMinimumDispValue collate sql_latin1_general_cp1_ci_as as PartySizeMinimumDispValue
	,MaxOnlineOptionID
	,PartySizeMaximumValue
	,PartySizeMaximumDispValue collate sql_latin1_general_cp1_ci_as as PartySizeMaximumDispValue
	,LargePartySizeValue
	,HowFarInAdvanceReservation collate sql_latin1_general_cp1_ci_as as HowFarInAdvanceReservation
	,HasProfilePhoto
	,IsOnRBRList
from 
	ROMS_RestaurantSummaryVW
		

go

GRANT EXECUTE ON [ROMS_GetWebRestaurantSummary1] TO ExecuteOnlyRole
go


