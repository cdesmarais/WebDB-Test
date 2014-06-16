if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBCheckI18nTableConventions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBCheckI18nTableConventions]
GO

CREATE Procedure dbo.DBCheckI18nTableConventions
As

--Case: Ensure illegal columns aren't used

SET NOCOUNT ON
create table #tables
(
TableName varchar(200),
ColName varchar(200)
)

--Illegal/ obsolete columns
insert into #tables values ('Restaurant', 'Rname')
insert into #tables values ('Restaurant', 'Address1')
insert into #tables values ('Restaurant', 'Address2')
insert into #tables values ('Restaurant', 'City')
insert into #tables values ('Restaurant', 'State')
insert into #tables values ('Restaurant', 'Chef')
insert into #tables values ('Restaurant', 'BanquetContact')
insert into #tables values ('Restaurant', 'CrossStreet')
insert into #tables values ('Restaurant', 'PrivatePartyContact')
insert into #tables values ('Restaurant', 'RealTZID')

insert into #tables values ('DiningStyle', 'DiningStyle')
insert into #tables values ('DressCode', 'DressCode')
insert into #tables values ('Holidays', 'HolidayName')
insert into #tables values ('Offer', 'Offer')
insert into #tables values ('Parking', 'Parking')
insert into #tables values ('MacroNeighborhood', 'MacroName')

insert into #tables values ('MetroArea', 'MetroAreaName')
insert into #tables values ('MetroArea', 'Message')
insert into #tables values ('MetroArea', 'TitleTag')
insert into #tables values ('MetroArea', 'ShortDisplayName')
insert into #tables values ('MetroArea', 'LanguageCode')
insert into #tables values ('MetroArea', 'ConnectionIssues')

insert into #tables values ('Neighborhood', 'NbhoodName')
insert into #tables values ('PaymentType', 'PaymentType')
insert into #tables values ('WalkinOption', 'WalkinOption')

insert into #tables values ('Country', 'countryName')
insert into #tables values ('Country', 'Delivery')
insert into #tables values ('Country', 'PriceDescription')
insert into #tables values ('Country', 'AddressFormat')

insert into #tables values ('PriceQuartile', 'PriceQuartile')
insert into #tables values ('PriceQuartile', 'MinPrice')
insert into #tables values ('PriceQuartile', 'IntlQuartile')

insert into #tables values ('CustomedDay', 'Message')

insert into #tables values ('BlockedDay', 'IntlQuartile')
insert into #tables values ('BlockedDay', 'Message')

insert into #tables values ('CreditCardDay', 'IntlQuartile')
insert into #tables values ('CreditCardDay', 'Message')

insert into #tables values ('ReferrerReservation', 'ReferrerID')
insert into #tables values ('ReferrerReservation', 'ResID')

insert into #tables values ('ReferrerRestaurantReservation', 'RID')
insert into #tables values ('ReferrerRestaurantReservation', 'ResID')

--***********************
--** Exceptions: Procs that are allowed to reference obsolte columns
--***********************
create table #Exceptions
(
ProcName varchar(200),
Reason varchar(2000)
)

insert into #Exceptions values ('Admin_Offer_Add', 'OK: populates both the local table and legacy table')
insert into #Exceptions values ('Admin_Offer_AddAllLanguages', 'OK: populates both the local table and legacy table')
insert into #Exceptions values ('Concierge_Reservation_Call_Add_WithCC', 'OK: populates the legacy table')
insert into #Exceptions values ('DNLogReservation', 'OK: populates the legacy table')
insert into #Exceptions values ('Reservation_Add_WithCC', 'OK: populates the legacy table')
insert into #Exceptions values ('Reservation_SaveReferrer', 'OK: populates the legacy table')
insert into #Exceptions values ('Reservation_SaveReferrer_Restaurant', 'OK: populates the legacy table')
insert into #Exceptions values ('ReferrerReservationVW', 'OK: needs to reference the legacy table')
insert into #Exceptions values ('ReferrerRestaurantReservationVW', 'OK: needs to reference the legacy table')


select		object_name(depid) [Table Name], 
			object_name(id) ProcName, 
			col_name(depid, depnumber) [Obsolete Column], 
			IsNull(e.Reason, 'NOT OK: Proc references obosolete column. Update proc to use view') [Explanation]
from		sysdepends
inner join	#tables t
on			object_name(depid) = t.tablename
and			col_name(depid, depnumber) = t.ColName
left join	#Exceptions e
on			e.ProcName = object_name(id)
where 		e.Reason is null
order by	Explanation asc, Procname, [Table Name]

drop table #tables
drop table #Exceptions
GO

GRANT EXECUTE ON [DBCheckI18nTableConventions] TO ExecuteOnlyRole

GO
