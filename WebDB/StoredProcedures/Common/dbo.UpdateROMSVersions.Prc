

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateROMSVersions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateROMSVersions]
GO


create procedure dbo.UpdateROMSVersions

as

set nocount on
set transaction isolation level read uncommitted


-- Insert the Product Versions if they do not exist
Insert into yellowstone.god.dbo.SoftwareProductVersions (SoftwareProductID, SoftwareProductVersionDesc, Active,Standard)
Select	Distinct '1' as SoftwareProductID,
		ERBVersion, 
		'1' as Active, 
		'0' as Standard
from	ERBRestaurant er 
where	coalesce(ERBVersion,'') != ''
and not exists(Select SoftwareProductVersionDesc from yellowstone.god.dbo.SoftwareProductVersions
where	er.ERBVersion = SoftwareProductVersionDesc COLLATE DATABASE_DEFAULT and SoftwareProductID = 1)

Insert into yellowstone.god.dbo.SoftwareProductVersions (SoftwareProductID, SoftwareProductVersionDesc, Active,Standard)
Select	Distinct '2' as SoftwareProductID, 
		ERBVersion, '1' as Active, '0' as Standard
from	ERBRestaurant er 
where	coalesce(ERBVersion,'') != ''
and not exists(Select SoftwareProductVersionDesc from yellowstone.god.dbo.SoftwareProductVersions
where	er.ERBVersion  = SoftwareProductVersionDesc COLLATE DATABASE_DEFAULT and SoftwareProductID = 2)

--*********************************
-- CURSOR Used for Update becuase linkserver is giving errors when direct update is performed:
-- Internal error. Buffer provided to read column value is too small. Run DBCC CHECKDB to check for any corruption. [SQLSTATE HY000] (Error 682).  The step failed.
--
-- this technique corrects the error
--*********************************
create table #ics_update (id int, value int)

declare UpdateValues CURSOR LOCAL READ_ONLY STATIC FOR
						select id, value from #ics_update

	
	
create table #jt (RestaurantID int, newerID int)

insert into #jt
select 		rt2.RestaurantID
			,spv.SoftwareProductVersionID 'newerID'
from       	Restaurant r
inner join 	ERBRestaurant er 
on         	r.RID = er.RID
and 		er.ERBVersion is not null
and 		er.ERBVersion <> ''
inner join 	yellowstone.god.dbo.Restaurants rt2
on         	cast(r.RID as nvarchar) = rt2.WebID
inner join 	yellowstone.god.dbo.SoftwareProductVersions spv
on 			er.ERBVersion = spv.SoftwareProductVersionDesc COLLATE DATABASE_DEFAULT
inner join 	yellowstone.god.dbo.SoftwareProducts sp
on 			spv.SoftwareProductId = sp.SoftwareProductID
and 		sp.SoftwareProductID = 1
						
						
insert into #ics_update
select ics.InventoryComputerSoftwareID
		, jt.NewerID
from   yellowstone.god.dbo.InventoryComputerSoftware ics 
inner join yellowstone.god.dbo.Inventory i
on i.InvID = ics.InvID
--and i.Active = 1
inner join yellowstone.god.dbo.Restaurants rt
on rt.RestaurantID = i.RestaurantID
inner join #jt jt
on rt.RestaurantID = jt.RestaurantID
where ics.SoftwareProductVersionID in (select SoftwareProductVersionID 
                                        from yellowstone.god.dbo.SoftwareProductVersions
                                        where SoftwareProductID = 1
                                        and active =1 )
and ics.SoftwareProductVersionID != jt.NewerID  -- Only fetch records that need to change
                                        
declare @CurStatus int
declare @id int
declare @value int

OPEN UpdateValues
FETCH NEXT FROM UpdateValues 
INTO @id, @value
set @CurStatus = @@FETCH_STATUS 

	while (@CurStatus = 0)
	begin

		update yellowstone.god.dbo.InventoryComputerSoftware 
		set    SoftwareProductVersionID = @value
		where  InventoryComputerSoftwareID = @id

		FETCH NEXT FROM UpdateValues 
		INTO @id, @value
		set @CurStatus = @@FETCH_STATUS 
	end
CLOSE UpdateValues
delete #ics_update

--------------------------------

create table #jt2 (RestaurantID int, newerID int)

insert into #jt2
select 		rt2.RestaurantID
			,spv.SoftwareProductVersionID 'newerID'
from       	Restaurant r
inner join 	ERBRestaurant er 
on         	r.RID = er.RID
and 		er.ERBVersion is not null
and 		er.ERBVersion <> ''
inner join 	yellowstone.god.dbo.Restaurants rt2
on         	cast(r.RID as nvarchar) = rt2.WebID
inner join 	yellowstone.god.dbo.SoftwareProductVersions spv
on 			er.ERBVersion = spv.SoftwareProductVersionDesc COLLATE DATABASE_DEFAULT
inner join 	yellowstone.god.dbo.SoftwareProducts sp
on 			spv.SoftwareProductId = sp.SoftwareProductID
and 		sp.SoftwareProductID = 2

insert into #ics_update
select ics.InventoryComputerSoftwareID, jt.NewerID
from   yellowstone.god.dbo.InventoryComputerSoftware ics 
inner join yellowstone.god.dbo.Inventory i
on i.InvID = ics.InvID
--and i.Active = 1
inner join yellowstone.god.dbo.Restaurants rt
on rt.RestaurantID = i.RestaurantID
inner join #jt2 jt 
on rt.RestaurantID = jt.RestaurantID
where ics.SoftwareProductVersionID in (select SoftwareProductVersionID 
                                        from yellowstone.god.dbo.SoftwareProductVersions
                                        where SoftwareProductID = 2
                                        and active =1 )
and ics.SoftwareProductVersionID != jt.NewerID  -- Only fetch records that need to change


OPEN UpdateValues
FETCH NEXT FROM UpdateValues 
INTO @id, @value
set @CurStatus = @@FETCH_STATUS 

	while (@CurStatus = 0)
	begin

		update yellowstone.god.dbo.InventoryComputerSoftware 
		set    SoftwareProductVersionID = @value
		where  InventoryComputerSoftwareID = @id

		FETCH NEXT FROM UpdateValues 
		INTO @id, @value
		set @CurStatus = @@FETCH_STATUS 
	end
CLOSE UpdateValues
delete #ics_update



---------------------------------------------

create table #jt3 (RestaurantID int, newerID int)

insert into #jt3
select 		rt.RestaurantID
			,spv.SoftwareProductVersionID 'newerID'
from       	Restaurant r
inner join 	ERBRestaurant er 
on         	r.RID = er.RID
and 		er.ERBVersion is not null
and 		er.ERBVersion <> ''
inner join 	yellowstone.god.dbo.Restaurants rt
on         	cast(r.RID as nvarchar) = rt.WebID
inner join 	yellowstone.god.dbo.SoftwareProductVersions spv
on 			er.ERBVersion = spv.SoftwareProductVersionDesc COLLATE DATABASE_DEFAULT
inner join 	yellowstone.god.dbo.SoftwareProducts sp
on 			spv.SoftwareProductId = sp.SoftwareProductID
and 		sp.SoftwareProductID = 1

insert into #ics_update
select ics.RestID, jt.NewerID
from   yellowstone.god.dbo.RestDSL ics 
inner join #jt3 jt 
on		ics.RestID = jt.RestaurantID
where	ics.OTVersionID in (select SoftwareProductVersionID 
                                        from yellowstone.god.dbo.SoftwareProductVersions
                                        where SoftwareProductID = 1
                                        and active =1 )
and		ics.OTVersionID != jt.NewerID -- only get records that need to change


OPEN UpdateValues
FETCH NEXT FROM UpdateValues 
INTO @id, @value
set @CurStatus = @@FETCH_STATUS 

	while (@CurStatus = 0)
	begin

		update yellowstone.god.dbo.RestDSL 
		set    OTVersionID = @value
		where  RestID = @id

		FETCH NEXT FROM UpdateValues 
		INTO @id, @value
		set @CurStatus = @@FETCH_STATUS 
	end
CLOSE UpdateValues
delete #ics_update

go

GRANT EXECUTE ON [UpdateROMSVersions] TO ExecuteOnlyRole

GO
