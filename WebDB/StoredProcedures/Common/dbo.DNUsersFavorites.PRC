if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUsersFavorites]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUsersFavorites]
GO

CREATE Procedure dbo.DNUsersFavorites(
	@GlobalPersonIdStart bigint,
	@NumberOfUsers int
)

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @TempGlobalPerson table
(
	GlobalPersonID bigint,
	Custid int,
	CallerId int
)

insert into @TempGlobalPerson
select Top(@NumberOfUsers)
	gp._GlobalPersonID as GlobalPersonID,
	gp.CustID as CustId,
	gp.CallerID as CallerId
from GlobalPerson gp
left outer join (
	select distinct cust.CustID
	from Customer cust
	inner join Favorites f on cust.CustID = f.CustID
	inner join Restaurant r on f.RID = r.RID
	where cust.Active = 1 and cust.ConsumerType <> 8 and r.RestStateID <> 4
) cust on gp.CustID = cust.CustID
left outer join (
	select distinct cal.CallerID
	from Caller cal
	inner join CallerRestaurants f on cal.CallerID = f.CallerID
	inner join Restaurant r on f.RID = r.RID
	where cal.CallerStatusID = 1 and r.RestStateID <> 4
) cal on gp.CallerID = cal.CallerID
where gp._GlobalPersonID > @GlobalPersonIdStart
	and (cust.CustID is not null or cal.CallerID is not null)
	and gp.RegionID = dbo.fGetRegionID()
order by gp._GlobalPersonID


	select 
		gp.GlobalPersonID,
		f.RID
	from Favorites f
	inner join @TempGlobalPerson gp on gp.Custid = f.CustID
	inner join Restaurant r on r.RID = f.RID
	where r.RestStateID <> 4
	and f.Migrated is null
union
	select distinct
		gp.GlobalPersonID,
		f.RID
	from CallerRestaurants f
	inner join @TempGlobalPerson gp on gp.CallerId = f.CallerID
	inner join Restaurant r on r.RID = f.RID
	where r.RestStateID <> 4
	and f.Migrated is null
GO

GRANT EXECUTE ON [DNUsersFavorites] TO ExecuteOnlyRole

GO