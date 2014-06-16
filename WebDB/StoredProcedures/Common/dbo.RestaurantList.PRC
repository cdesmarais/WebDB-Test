if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantList]
GO

--*******************************************
--** Proc Used by OTAnywhere
--*******************************************
create procedure dbo.RestaurantList
 
@loginid  int

as 

set nocount on
set transaction isolation level read uncommitted

declare @otuser      bit
       ,@groupadmin  bit
       ,@groupid     int
--get their group id

select @otuser     = otuser
      ,@groupid    = groupid
      ,@groupadmin = groupadmin
from    login
where   loginid = @loginid
and     active  = 1
if @otuser = 1
--opentable employee,return all restaurants
--************************************************************
begin
  select     rest.RID
            ,rest.Rname as name
            ,RestStateID
            ,IsReachable
  from       RestaurantVW rest
  inner join ERBRestaurant er
  on         rest.RID  = er.RID
  where      ProductID          = 6
  and        RestStateID = 1
  order by   rest.Rname
  return
end  
--************************************************************

if @groupadmin = 1
--group admin
--          (this will return all restaurants for this group)
--************************************************************
begin
  select    restaurantmembers.RID
           ,rest.name
           ,IsReachable
  from      login
--this will act like the base table
  inner join restaurantmembers 
  on         login.groupid                   = restaurantmembers.groupid
--this join ensures the groupid is valid
  inner join restaurantgroups 
  on         restaurantmembers.groupid       = restaurantgroups.groupid
--this gets Restaurant info from the web db
  inner join RestaurantVW rest 
  on         restaurantmembers.RID = rest.RID
--this gets erb login info from the web db
  inner join ERBRestaurant erb 
  on         restaurantmembers.RID = erb.RID
  where      login.active                    = 1 
  and        restaurantgroups.active         = 1
  and        restaurantmembers.groupid       = @groupid
  and        loginid                         = @loginid
  and        rest.RStateID        <> 4
  return
end

--************************************************************
else
--regular user
--          (this will only return restaurants that this user has been specified)
--************************************************************
begin
  select     loginrestaurants.RID
           ,rest.name
           ,IsReachable
  from       loginrestaurants
--this join ensures the loginid is a valid one
  inner join login 
  on         loginrestaurants.loginid = login.loginid
--this join ensures the Restaurant in loginrestaurants is a valid Restaurant for this group
  inner join restaurantmembers 
  on         loginrestaurants.RID = restaurantmembers.RID
--this join ensures the groupid is valid
  inner join restaurantgroups 
  on         restaurantmembers.groupid = restaurantgroups.groupid
--this gets Restaurant info from the web db
  inner join RestaurantVW rest 
  on         loginrestaurants.RID = rest.RID
--this gets erb login info from the web db
  inner join ERBRestaurant erb 
  on         loginrestaurants.RID = erb.RID
  where      login.active = 1            --active users
  and        restaurantgroups.active = 1 --active Restaurant groups
  and        restaurantmembers.groupid = @groupid --groupid
  and        loginrestaurants.loginid  = @loginid --loginid
  and        rest.RStateID  = 1
  return
end
--************************************************************



GO

GRANT EXECUTE ON [RestaurantList] TO ExecuteOnlyRole

GO
