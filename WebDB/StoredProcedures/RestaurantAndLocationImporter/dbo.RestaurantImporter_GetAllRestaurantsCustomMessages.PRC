if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllRestaurantsCustomMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllRestaurantsCustomMessages]
go

create Procedure dbo.RestaurantImporter_GetAllRestaurantsCustomMessages
as

set transaction isolation level read uncommitted
set nocount on

select distinct 
			cd.rid
			,CustomedDate
			,Message
			,cd.LanguageID
			,DetailsPageOnly
			,mao.Days
from		CustomedDayAVW				cd
inner join	Restaurant				r
on			r.rid					= cd.rid
inner join	MaxAdvanceOption mao
on			mao.MaxAdvanceOptionID	= r.MaxAdvanceOptionID
where CustomedDate between dateadd(day, datediff(day, 1, getdate()),0) and getdate() +  mao.Days + 1

go

grant execute on [RestaurantImporter_GetAllRestaurantsCustomMessages] to ExecuteOnlyRole

go	