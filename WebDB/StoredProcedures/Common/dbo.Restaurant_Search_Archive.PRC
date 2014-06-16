if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Search_Archive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Search_Archive]
GO

CREATE PROCEDURE dbo.Restaurant_Search_Archive

AS

set nocount on
set transaction isolation level read uncommitted

declare  @rowcount int
        ,@error    int

begin transaction
save transaction Restaurant_Search_Archive

if exists(select SearchID from SearchLog where SearchTypeID = 1)
begin
insert SearchByRestaurant
	(SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,RID
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,ActiveUser
	,UIType
	,PartnerID
	,MultiSearch
	)
select
	SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,RIDs
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,case when(select count(CustID)
				from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
				where RStateID not in (3,4,8,9,10)
				and r.CallerID is null
				and r.CustID = sl.CustID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1
	      when(select count(CallerID)
				from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
				where RStateID not in (3,4,8,9,10)
				and r.CallerID = sl.CallerID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1 else 0 end
	,UIType
	,case when(sl.CustID>0) then (Select PartnerID from Customer rc where rc.CustID = sl.CustID)
	when(sl.CallerID>0) then (Select PartnerID from Caller c where c.CallerID = sl.CallerID) else 0 end,
	case when(CHARINDEX(',',RIDs) > 0) then 1 else 0 end

From SearchLog sl
Where SearchTypeID = 1
Order By SearchID

select  @rowcount = @@rowcount
           ,@error    = @@error
if @rowcount  = 0
    or @error    != 0
      begin

        rollback transaction Restaurant_Search_Archive
        RAISERROR('Restaurant error',17,1)
        commit transaction
        return -1
      end
else
      begin
	delete
	from SearchLog
	where SearchTypeID = 1
      end
end
if exists(select SearchID from SearchLog where SearchTypeID = 2)
begin
insert SearchByNeighborhood
	(SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,NeighborhoodID
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,FoodType
	,PriceRange
	,ActiveUser
	,UIType
	,PartnerID	
	)
select
	SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,NeighborhoodID
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,FoodType
	,PriceRange
	,case when(select count(CustID)
			from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
			where RStateID not in (3,4,8,9,10)
				and r.CallerID is null
				and r.CustID = sl.CustID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1
	      when(select count(CallerID)
			from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
			where RStateID not in (3,4,8,9,10)
				and r.CallerID = sl.CallerID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1 else 0 end
	,UIType
	,case when(sl.CustID>0) then (Select PartnerID from Customer rc where rc.CustID = sl.CustID)
	when(sl.CallerID>0) then (Select PartnerID from Caller c where c.CallerID = sl.CallerID) else 0 end

From SearchLog sl
Where SearchTypeID = 2
Order By SearchID

select  @rowcount = @@rowcount
           ,@error    = @@error
if @rowcount  = 0
    or @error    != 0
      begin

        rollback transaction Restaurant_Search_Archive
        RAISERROR('Neighborhood error',17,1)
        commit transaction
        return -2
      end
else
      begin
	delete
	from SearchLog
	where SearchTypeID = 2
      end
end
if exists(select SearchID from SearchLog where SearchTypeID = 3)
begin
insert SearchByMacroNeighborhood
	(SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,MacroID
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,FoodType
	,PriceRange
	,ActiveUser
	,UIType
	,PartnerID
	)
select
	SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,MacroID
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,FoodType
	,PriceRange
	,case when(select count(CustID)
			from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
			where RStateID not in (3,4,8,9,10)
				and r.CallerID is null
				and r.CustID = sl.CustID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1
	      when(select count(CallerID)
			from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
			where RStateID not in (3,4,8,9,10)
				and r.CallerID = sl.CallerID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1 else 0 end
	,UIType
	,case when(sl.CustID>0) then (Select PartnerID from Customer rc where rc.CustID = sl.CustID)
	when(sl.CallerID>0) then (Select PartnerID from Caller c where c.CallerID = sl.CallerID) else 0 end

From SearchLog sl
Where SearchTypeID = 3
Order By SearchID

select  @rowcount = @@rowcount
           ,@error    = @@error
if @rowcount  = 0
    or @error    != 0
      begin

        rollback transaction Restaurant_Search_Archive
        RAISERROR('Macro error',17,1)
        commit transaction
        return -3
      end
else
      begin
	delete
	from SearchLog
	where SearchTypeID = 3
      end
end
if exists(select SearchID from SearchLog where SearchTypeID = 4)
begin
insert SearchByFavorite
	(SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,ActiveUser
	,UIType
	,PartnerID
	)
select
	SearchID
	,CustID
	,CallerID
	,SearchMetroAreaID
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,case when(select count(CustID)
			from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
			where RStateID not in(3,4,8,9,10)
				and r.CallerID is null
				and r.CustID = sl.CustID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1
	      when(select count(CallerID)
			from Reservation r
				inner join Restaurant rest on rest.RID = r.RID
				inner join Neighborhood n on n.NeighborhoodID = rest.NeighborhoodID
			where RStateID not in(3,4,8,9,10)
				and r.CallerID = sl.CallerID
				and datediff(month,r.ShiftDate,getdate()) between 1 and 3
				and n.MetroAreaID <> 1) > 0 then 1 else 0 end
	,UIType
	,case when(sl.CustID>0) then (Select PartnerID from Customer rc where rc.CustID = sl.CustID)
	when(sl.CallerID>0) then (Select PartnerID from Caller c where c.CallerID = sl.CallerID) else 0 end

From SearchLog sl
Where SearchTypeID = 4
Order By SearchID

select  @rowcount = @@rowcount
           ,@error    = @@error
if @rowcount  = 0
    or @error    != 0
      begin

        rollback transaction Restaurant_Search_Archive
        RAISERROR('Favorite error',17,1)
        commit transaction
        return -3
      end
else
    begin
	delete
	from SearchLog
	where SearchTypeID = 4
    end
end

commit transaction


GO

GRANT EXECUTE ON [Restaurant_Search_Archive] TO ExecuteOnlyRole

GO
