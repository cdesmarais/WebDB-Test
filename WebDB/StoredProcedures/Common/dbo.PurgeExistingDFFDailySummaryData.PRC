if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PurgeExistingDFFDailySummaryData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[PurgeExistingDFFDailySummaryData]
go


create procedure [dbo].[PurgeExistingDFFDailySummaryData] 
as
begin
	set transaction isolation level read uncommitted
	declare @domainID int

	select top (1) @domainID = IsNull(DomainID, 0)
	from dbo.DBUser 
	where DBUser = User

	delete from dbo.DffDailySummaryRIDStatsHolding
	where WebRID in (
		select RID
		from dbo.Restaurant
		where DomainID = @domainID
	)
end
go

grant execute on [PurgeExistingDFFDailySummaryData] TO ExecuteOnlyRole
go