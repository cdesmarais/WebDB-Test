if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUsersFavoritesMarkAsMigrated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUsersFavoritesMarkAsMigrated]
GO

CREATE Procedure dbo.DNUsersFavoritesMarkAsMigrated(
	@GlobalPersonIds nvarchar(4000)
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
select _GlobalPersonID, CustID, CallerID
from GlobalPerson gp
inner join fStringsToTab(@GlobalPersonIds, ',') u on u.StringValues = gp._GlobalPersonID
where gp.RegionID = dbo.fGetRegionID()

update Favorites
set Migrated = 1
where CustID in (select CustID from @TempGlobalPerson gp where gp.CustID is not null)

update CallerRestaurants
set Migrated = 1
where CallerID in (select CallerId from @TempGlobalPerson gp where gp.CallerId is not null)

GO

GRANT EXECUTE ON [DNUsersFavoritesMarkAsMigrated] TO ExecuteOnlyRole

GO