if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenMostBookedMetroList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[TopTenMostBookedMetroList]
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE TopTenMostBookedMetroList
	@DayHorizon int = 30,
	@EndDate datetime = null
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION isolation LEVEL READ uncommitted
	
	declare @MinResID int
	declare @MaxResID int

	set @EndDate = dateadd(day, datediff(day, 0, isnull(@EndDate,getdate())),0)  -- midnight
	select @MinResID = min(resid) from Reservation where shiftdate > DATEADD(day, -(@DayHorizon + 30), @EndDate) and DateMade > DATEADD(day, -@DayHorizon, @EndDate)
	select @MaxResID = min(resid) from Reservation where shiftdate > DATEADD(day, -31, @EndDate) and DateMade > DATEADD(day, -1, @EndDate)

	if object_id('tempdb..#temp') is not null
		drop table #temp

	create table #temp (RID int)

	insert	Into #temp
	select	distinct rid
	from	Reservation 
	where	ShiftDate > DATEADD(day, -(@DayHorizon + 30), @EndDate)
	and		ResID >= @MinResID  
	and		ResID < @MaxResID   
	and		RStateID in (1,2,5,7) /*1 = Pending, 2 = Seated, 5 = Assumed Seated, 7 = Seated Disputed */ 
	and		companyid is null /*Exclude concierge reservations*/   





	select distinct MA.MetroAreaID
	from #temp Resv

	inner join Restaurant Rest 
	on Resv.RID = Rest.RID 

	inner join FoodTypes FTS with (index (FoodTypes_PK))              
	on Rest.RID = FTS.RID         

	inner join FoodType FT        
	on FTS.FoodTypeID = FT.FoodTypeID 

	inner join Neighborhood NBH          
	on Rest.NeighborhoodID = NBH.NeighborhoodID         

	inner join MetroArea MA        
	on NBH.MetroAreaID = MA.MetroAreaID        

	inner join MacroNeighborhood MNH        
	on NBH.MacroID = MNH.MacroID  

	where MA.active = 1
	and MA.MetroAreaID <> 1
	and NBH.Active = 1  
	and MNH.Active = 1    
	and Rest.RID not in (select ValueId from valuelookupmaster a 
						  inner join valuelookupidlist b on  
						  b.LookupID = a.LookupID 
						  where [Type] = 'WEBSERVER' and [Key] = 'TopTenRIDGlobalBlackList')  
	and FTS.IsPrimary = 1    
	and Rest.RestStateID = 1

	order by MA.MetroAreaID



	if object_id('tempdb..#temp') is not null
		drop table #temp
	
END
GO

grant execute on [TopTenMostBookedMetroList] TO ExecuteOnlyRole

go