

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_Get_Restaurants_IncentiveStatus2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ROMS_Get_Restaurants_IncentiveStatus2]
go

create procedure  [dbo].[ROMS_Get_Restaurants_IncentiveStatus2]
(
	@ROMSIDList varchar(8000)=null  
)
as
begin   

	/* 
	This stored procedure is used to get the DIP status Infromtaion from WebDB and WebDB_EU..
	@ROMSIDList list is optional, host can pass comma seprated RID's  
	*/

	-- Used to get retstaurant's DIP Status information.. from WebDB.
	select 
		 incentiveVW.DIPStatus as DIPStatus
		,incentiveVW.DIPCreateDate as DIPCreateDate
		,incentiveVW.DIPCancellationDate as DIPCancellationDate
		,incentiveVW.RestDIPStatusTypeID as RestDIPStatusTypeID
		,incentiveVW.WebRID as WebRID		
	from 
		IncentiveRestaurantStatusVW as incentiveVW
	where 
		(@ROMSIDList is null or charindex(',' + cast( incentiveVW.WebRID as nvarchar) + ',', ',' + @ROMSIDList + ',')>0 )
		and incentiveVW.Active = 1

end

GO

GRANT EXECUTE ON [ROMS_Get_Restaurants_IncentiveStatus2] TO ExecuteOnlyRole

GO 

