

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_GetRestaurantCutOffTimes1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ROMS_GetRestaurantCutOffTimes1]
go

/* 
	Stored procedure to get combined Cut OFF time information of all restaurants belonging to different Regional WebDB's. 
	This stored procedure is used by PJR Job that transfers Cut OFF time info from WebDB to GOD database.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

create procedure dbo.ROMS_GetRestaurantCutOffTimes1

as  
 
select 
	WebRID
	,ResCutOffTime
	,CutOffDay collate sql_latin1_general_cp1_ci_as as CutOffDay
	,CloseTime
	,Shift collate sql_latin1_general_cp1_ci_as as Shift
	,Rank
 from 
	RestaurantCutOffTimesVW
		

go

GRANT EXECUTE ON [ROMS_GetRestaurantCutOffTimes1] TO ExecuteOnlyRole
go


