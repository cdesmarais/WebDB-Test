if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateFeaturedPOPByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateFeaturedPOPByRID]
GO

create procedure [dbo].[Admin_Restaurant_UpdateFeaturedPOPByRID]
(
	@RID  		int,
	@SlotNum 	int,
	@StartDate 	date,
	@EndDate 	date,
	@UpdatedBy	nvarchar(255)
)
as
	set transaction isolation level read uncommitted
	set nocount on
	
	declare @cRID  int, @metroID int
	declare @cRestName 	nvarchar(255),  @sMsg nvarchar(255)
	declare @updateTime datetime, @currentDate date
	
	
	select @metroID = n.MetroAreaID
	from RestaurantVW r
	inner join NeighborhoodVw n
	on r.NeighborhoodID = n.NeighborhoodID
	where r.RID = @RID
		
	
	IF EXISTS(
		select 1
		from RestaurantFeaturedPOPList rl
		inner join RestaurantVW  r
		on rl.RID =  r.RID
		inner join NeighborhoodVw n
		on r.NeighborhoodID = n.NeighborhoodID
		where
			r.RID != @RID AND SlotNum = @SlotNum  
			AND n.MetroAreaID = @metroID
			AND (@startDate <= EndDate  
				AND   StartDate <= @EndDate)			
	)
	BEGIN
		select top 1 @cRID=rl.RID, @cRestName=RName 
		from RestaurantFeaturedPOPList  rl
		inner join RestaurantVW  r
		on rl.RID = r.RID
		inner join NeighborhoodVw n
		on r.NeighborhoodID = n.NeighborhoodID
		where
			rl.RID != @RID AND SlotNum = @SlotNum
			AND n.MetroAreaID = @metroID
			AND (@startDate <= EndDate  
				AND   StartDate <= @EndDate)	
		
		Set @sMsg = @cRestName  + '- RID: ' + CAST (@cRID as nvarchar(10))
		RAISERROR (@sMsg, 16, 1)
		RETURN
	END

	set @updateTime = getdate()
	set @currentDate = @updateTime
	
	IF EXISTS (
		select 1
		from RestaurantFeaturedPOPList
		where
			RID = @RID 
			AND EndDate >= @currentDate
	) 
	BEGIN
		--update 
		update RestaurantFeaturedPOPList 
			set StartDate = @StartDate
				,EndDate = @EndDate
				,SlotNum = @SlotNum
				,UpDatedBy = @UpdatedBy
				,UpdateTime = @UpdateTime
		where RID = @RID  AND 
			EndDate >= @currentDate
	END  ELSE
	BEGIN
		--insert
		insert into RestaurantFeaturedPOPList (
			RID, SlotNum, StartDate, EndDate, UpdatedBy, UpdateTime
			)  values (
			@RID, @SlotNum, @StartDate, @EndDate, @UpdatedBy, @UpdateTime
			)
	END
	
	RETURN @@Error
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateFeaturedPOPByRID] TO ExecuteOnlyRole
GO
