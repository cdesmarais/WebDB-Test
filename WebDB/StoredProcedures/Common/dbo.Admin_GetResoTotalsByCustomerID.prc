if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetResoTotalsByCustomerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetResoTotalsByCustomerID]
go

create procedure dbo.Admin_GetResoTotalsByCustomerID 
	 @CustID	int
	,@IsCaller	bit
as
	set nocount on
	set transaction isolation level read uncommitted

	if @IsCaller = 0
	begin 
		select	 coalesce(sum( case when RStateID = 2	then 1 else 0 end )	,0)	seated_count				
				,coalesce(sum( case when RStateID = 4	then 1 else 0 end )	,0)	noshow_count				
				,coalesce(sum( case when RStateID = 5	then 1 else 0 end )	,0)	seated_assumed_count		
				,coalesce(sum( case when RStateID = 10	then 1 else 0 end )	,0)	noshow_excused_count		
				,coalesce(sum( case when RStateID = 7	then 1 else 0 end )	,0)	seated_disputed_count		
				,coalesce(sum( case when RStateID = 3	then 1 else 0 end )	,0)	cancelled_web_count			
				,coalesce(sum( case when RStateID = 8	then 1 else 0 end )	,0)	cancelled_restaurant_count	
				,coalesce(sum( case when RStateID = 9	then 1 else 0 end )	,0)	cancelled_disputed_count	
				,coalesce(count(*)											,0)	reservation_count			
				,coalesce(sum( case when RStateID not in (3,4,8,9,10) then 1 else 0 end )	,0)	pending_seated_count	
		from	Reservation	r
		where	r.CustID = @CustID
	end
	else
	begin
		select	 coalesce(sum(case when RStateID = 2	then 1 else 0 end)	,0)	seated_count				
				,coalesce(sum(case when RStateID = 4	then 1 else 0 end)	,0)	noshow_count				
				,coalesce(sum(case when RStateID = 5	then 1 else 0 end)	,0)	seated_assumed_count		
				,coalesce(sum(case when RStateID = 10	then 1 else 0 end)	,0)	noshow_excused_count		
				,coalesce(sum(case when RStateID = 7	then 1 else 0 end)	,0)	seated_disputed_count		
				,coalesce(sum(case when RStateID = 3	then 1 else 0 end)	,0)	cancelled_web_count			
				,coalesce(sum(case when RStateID = 8	then 1 else 0 end)	,0)	cancelled_restaurant_count	
				,coalesce(sum(case when RStateID = 9	then 1 else 0 end)	,0)	cancelled_disputed_count	
				,coalesce(count(*)											,0)	reservation_count			
				,coalesce(sum(case when RStateID not in (3,4,8,9,10) then 1 else 0 end )	,0)	pending_seated_count	
		from	Reservation	r
		where	r.CallerID	= @CustID
	end
go

	grant execute on [Admin_GetResoTotalsByCustomerID] to ExecuteOnlyRole
go

