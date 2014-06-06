if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AttributionService_GetRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AttributionService_GetRestaurants]
GO

create procedure dbo.AttributionService_GetRestaurants
as
set nocount on
set transaction isolation level read uncommitted

DECLARE @ExclusivevilleId int = 58
	
SELECT 
	r.RID, 
	case 
		when n.MetroAreaID = @ExclusivevilleId then convert(bit, 1)
		else convert(bit, 0) 
		end			as InExclusiveville
FROM		Restaurant r
inner JOIN	Neighborhood n
on			n.NeighborhoodID = r.NeighborhoodID
where		r.RestStateID not in (4,11,15)
and			n.MetroAreaID = @ExclusivevilleId

go

grant execute on [AttributionService_GetRestaurants] to ExecuteOnlyRole

GO