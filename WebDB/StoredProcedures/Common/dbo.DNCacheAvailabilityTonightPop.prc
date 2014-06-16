if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheAvailabilityTonightPop]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheAvailabilityTonightPop]
go

create procedure dbo.DNCacheAvailabilityTonightPop 
as 
begin

	exec procCacheAvailabilityTonight 1
	
end 
go
	


GRANT EXECUTE ON [DNCacheAvailabilityTonightPop] TO ExecuteOnlyRole
go
