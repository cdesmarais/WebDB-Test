if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_FtpBackupStatusQuery]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ROMS_FtpBackupStatusQuery]
GO

CREATE proc dbo.ROMS_FtpBackupStatusQuery
as
       --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
       set nocount on 
       set transaction isolation level read uncommitted
       declare       @rowcount  int
                     ,@error     int
                     ,@rc        int
       --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--yellowstone.god.dbo.Restaurants
if object_id(N'tempdb..#ROMS_Restaurants') is not null
		drop table #ROMS_Restaurants
create table #ROMS_Restaurants(WebID varchar(50), RestaurantID int, iWebID int)

insert into #ROMS_Restaurants (WebID, RestaurantID, iWebID)
Select WebID, RestaurantID, CAST(WebID as int) from  yellowstone.god.dbo.Restaurants
where ISNUMERIC(WebID) > 0

--yellowstone.god.dbo.RestDSL
if object_id(N'tempdb..#ROMS_RestDSL') is not null
		drop table #ROMS_RestDSL
create table #ROMS_RestDSL(RestID int, AdToolStatusChangeDate datetime)

insert into #ROMS_RestDSL (RestID, AdToolStatusChangeDate)
Select RestID, AdToolStatusChangeDate from  yellowstone.god.dbo.RestDSL

-- yellowstone.god.dbo.OTStdAccount
if object_id(N'tempdb..#ROMS_OTStdAccount') is not null
		drop table #ROMS_OTStdAccount
create table #ROMS_OTStdAccount(SAID int , OSAccountType int)

insert into #ROMS_OTStdAccount (SAID, OSAccountType)
Select SAID, OSAccountType from yellowstone.god.dbo.OTStdAccount


-- yellowstone.god.dbo.RestOSAccount
if object_id(N'tempdb..#ROMS_RestOSAccount') is not null
		drop table #ROMS_RestOSAccount
create table #ROMS_RestOSAccount(AccountName varchar(50), RestID int, OTStdAccount int)

insert into #ROMS_RestOSAccount(AccountName, RestID, OTStdAccount)
Select AccountName, RestID, OTStdAccount from yellowstone.god.dbo.RestOSAccount roa1
inner join #ROMS_OTStdAccount osa1
on osa1.SAID      = roa1.OTStdAccount
where  osa1.OSAccountType    = 2 -- FTP



       select        coalesce(roa.AccountName,'00000000')    'AcctName',
                           r.RName                                                      'RestName'
                           ,r.RID                                                        'RestID'
                           ,r.RestStateID                                                'RestState'
                           ,er.ERBVersion                                                'RestVersion'
                           ,rs.RState                                                    'RestStateName'
                           ,r.IsReachable                                                'IsReachable'
                           ,er.ProductID                                          'ProductID'
                           ,rd.AdToolStatusChangeDate                      'LastStatusChange'
       from          RestaurantVW r
       inner join    ERBRestaurant er
       on                   er.RID                     = r.RID
       inner join    RestaurantState rs
       on                   rs.RestStateID             = r.RestStateID
       inner join    NeighborhoodAVW n
       on                   n.NeighborhoodID     = r.NeighborhoodID
       and                  n.LanguageID         = r.LanguageID
       inner join    MetroAreaAVW ma
       on                   ma.MetroAreaID             = n.MetroAreaID
       and                  ma.LanguageID        = r.LanguageID
       inner join    #ROMS_Restaurants rt
       on                   rt.iWebID                   = r.RID 
       inner join    #ROMS_RestDSL rd
       on                   rd.RestID                  = rt.RestaurantID
       left join     #ROMS_RestOSAccount roa
       on                   roa.RestID                 = rt.RestaurantID

       where		ma.Active               = 1 -- Active metro
       and          r.RestStateID			!= 4 -- Not inactive
       and          r.Allotment             != 1 -- Not allotment
      order by      AcctName

if object_id(N'tempdb..#ROMS_Restaurants') is not null
		drop table #ROMS_Restaurants
if object_id(N'tempdb..#ROMS_RestDSL') is not null
		drop table #ROMS_RestDSL
if object_id(N'tempdb..#ROMS_OTStdAccount') is not null
		drop table #ROMS_OTStdAccount
if object_id(N'tempdb..#ROMS_RestOSAccount') is not null
		drop table #ROMS_RestOSAccount	
return 0

go

GRANT EXECUTE ON [ROMS_FtpBackupStatusQuery] TO ExecuteOnlyRole
GO