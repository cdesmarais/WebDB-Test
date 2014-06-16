if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUpdateCheckRedemptionBlacklist]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUpdateCheckRedemptionBlacklist]
go

create procedure dbo.JobUpdateCheckRedemptionBlacklist 
as 
begin

	--deprecated, this proc is now obsolete
	
	return 0
	end
go

GRANT EXECUTE ON [JobUpdateCheckRedemptionBlacklist] TO ExecuteOnlyRole

GO
