if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUpdateTop10RestaurantList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUpdateTop10RestaurantList]
GO

CREATE PROCEDURE dbo.JobUpdateTop10RestaurantList
AS
SET NOCOUNT ON
--****************************************************************
--** This procedure is to replace Report_Restaurant_Insert_Top10
--** Use a Res ID range to do the lookup (keep everything PK based)
--****************************************************************
declare @MaxResid int, @MinResid int, @i int, @rowlist int, @offSet int
declare @MinDateMade datetime, @MaxDateMade datetime, @fromDate datetime,@thruDate datetime


--Get time period of 7 days
set @thrudate = Cast(convert(nvarchar, getdate(), 101) as datetime)
set @fromDate = DateAdd(d, -7, @thrudate)


--***********************************
--** Create a temp table and use the ResID range we found in @maxResID and @MinResID
--** #TempRank table assigns ID which will be used as rank
--***********************************
CREATE TABLE #TempRank (RowNumber int IDENTITY (1, 1)
                        ,MetroAreaID int
						,RID int 
                        ,resos int )


--Insert into #TempRank
set transaction isolation level read uncommitted
Insert into #TempRank (MetroAreaID, RID, Resos)
select MetroArea.MetroAreaID, r.RID,  count(1) Reso
from reservation r
inner join Restaurant rt 
on         r.RID = rt.RID
inner join Neighborhood n 
on         rt.NeighborhoodID = n.NeighborhoodID
inner join MetroArea MetroArea 
on         n.MetroAreaID = MetroArea.MetroAreaID
where 
	-- Trick to Quickly issolate data to appropriate partition; 
	-- Impossible for a Reso to have a datemade that is smaller than the shiftdate; 
	-- there are some cases when an ERB change trickles in late but there is a 30 day limit on these
	-- However it is possible for a reso to have a ShiftDate much greater than datemade (reso can be made far into the future)
	ShiftDate >= dateadd(dd, -30, @fromDate)

and	  datemade between @fromDate and @thruDate
and   r.RStateID in (1,2,5,6,7)
and   r.CompanyID is NULL
and   MetroArea.toptenlist = 1 
and   RestStateID in (1,5,6,7,16,13)
group by R.rid, MetroArea.MetroAreaID
order by MetroArea.MetroAreaID Asc, Reso Desc, R.RID Asc

Begin Transaction

	DELETE FROM RestaurantTopList
	if (@@ERROR <> 0) goto general_error

	set @i = 1
	Select @rowlist=max(MetroAreaID) from MetroArea

	-- Loop through each single MetroAreaID and insert the top 10 into RestaurantTopList table
	While @i <= @rowlist
	BEGIN

		select @offset = min(RowNumber)-1 from #TempRank where MetroAreaID = @i
		Insert into RestaurantTopList
		(Rank, RID,Resos)
		select top 10 (RowNumber-@offset), RID, Resos from #TempRank where 
		MetroAreaID = @i order by Resos desc, RID Asc
		if (@@ERROR <> 0) goto general_error
		Set @i = @i + 1
	END

	--This is to make sure we only have top 10 ranking else it's a failure in Rank ID generation
	select count(*) from  RestaurantTopList group by Rank
	If (@@rowcount)<>10 goto general_error
COMMIT TRANSACTION

drop table #TempRank
Return(0)

general_error:
	ROLLBACK TRANSACTION
	raisError ('throw error',15, 1)
	Return(0)
GO


GRANT EXECUTE ON [JobUpdateTop10RestaurantList] TO ExecuteOnlyRole

GO
