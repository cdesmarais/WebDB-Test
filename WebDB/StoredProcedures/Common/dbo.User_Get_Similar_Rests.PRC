if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Get_Similar_Rests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Get_Similar_Rests]
GO

CREATE Procedure dbo.User_Get_Similar_Rests
(
  @Restaurant_ID int,
  @MacroID int,
  @userList nvarchar(1000) output
)
AS

--PROCEDURE IS NOW MOVED TO OTREPORTS
--REPLACED BY WEBAGG_USER_GET_SIMILAR_RESTS
--
--*****************************************************************************
--** User_Get_Similar_Rests
--**
--** Return a list of the most popular restaurants (by reervations) 
--** based on diners reservation activity for specific restaurant.
--** Diners who ate at restaurant A also ate at restaurant B, C, D, etc...
--**
--*****************************************************************************
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Declare @Reso_Count int
	Declare @near_rid int

	--** If no MacroID provided then look it up
	if (@MacroID is null)
	begin
		Select    @MacroID = MacroID 
		from       Restaurant r
		inner join Neighborhood n  
		on         r.neighborhoodid = n.neighborhoodid
		where      RID = @Restaurant_ID
	end
  

	declare user_pick_cur CURSOR LOCAL READ_ONLY STATIC 
	FOR
    --***********************
    --** Set 3: top 10 restaurants by reservation count
    --** for all restaurants found in Set 2.
	--** rder by reservation count desc (most popular to least popular)
    --***********************
	Select top 10 r.RID as Restaurant_ID
			  ,sum(RestList.Resos) as Reso_Count 
	from      Restaurant r
	join      (
			   --***********************
			   --** Set 2: restaurants that were dined at
			   --** by users in Set 1; with count of number of times reserved
			   --** group by restuarant and user
			   --** Only include users that have dined in last 6 months
			   --** Only include restaurants that are currently active
			   --***********************
			   Select     r.RID
						 ,Reservation.CustID
						 ,count(Reservation.CustID) Resos
			   from       Reservation
			   join      (
						  --***********************
						  --** Set 1: customers that ate at specified restaurant  
						  --**		  must have dined at least twice
						  --**		  in the past 6 months
						  --***********************
						  Select     count(ResID) as Reso
									,CustID
									,null as CallerID 
						  from       Reservation 
						  inner join Restaurant r
						  on         Reservation.RID = r.RID
						  inner join Neighborhood n 
						  on         r.neighborhoodid = n.neighborhoodid
						  where      Reservation.RID = @Restaurant_ID 
						  and        CallerID is null 
						  and        MacroID = @MacroID 
						  and        DATEDIFF(mm,ShiftDate,getdate()) < 7
						  group by   CustID
						  having     count(ResID) >= 2
						  ) as UserResos 
			   on         Reservation.CustID = UserResos.CustID
			   inner join Restaurant r
			   on         Reservation.RID = r.RID
			   inner join Neighborhood n 
			   on         r.neighborhoodid = n.neighborhoodid
			   where      MacroID = @MacroID 
			   and		  r.RID <> @Restaurant_ID
			   and		  r.RestStateID = 1
			   and        DATEDIFF(mm,ShiftDate,getdate()) < 7 
			   group by   r.RID
						 ,Reservation.CustID
			   Having     count(Reservation.CustID) > 1
			   ) as RestList 
	on         r.RID = RestList.RID
	group by   r.RID
	order by   sum(RestList.Resos)  desc


	set @userList = ''
	--** Iterate through results and construct a return string
	--** In the following format: RID/Distance, RID/Distance, ...
	--** NOTE: Distance is converted from miles to feet
	OPEN user_pick_cur
	FETCH NEXT FROM user_pick_cur 
	INTO @near_rid, @Reso_Count

	declare @count int
	set @count = 0
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if (@count > 0)
			set @userList = @userList + ','
			
		set @userList = @userList +  cast(@near_rid as nvarchar) + '/' + cast(@Reso_Count as nvarchar)
		
		set @count = @count + 1
		FETCH NEXT FROM user_pick_cur 
		INTO @near_rid, @Reso_Count
	END
	CLOSE user_pick_cur

	if (@userList = '')
		set @userList = null

	if (@@ERROR <> 0)
		goto general_error

	Return(0)

general_error:
	Return('User_Get_Similar_Rests FAILED: ' + cast(@@ERROR as nvarchar))
GO

GRANT EXECUTE ON [User_Get_Similar_Rests] TO ExecuteOnlyRole

GO
