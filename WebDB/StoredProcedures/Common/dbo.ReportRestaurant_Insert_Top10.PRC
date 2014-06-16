if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReportRestaurant_Insert_Top10]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReportRestaurant_Insert_Top10]
GO


CREATE PROCEDURE dbo.ReportRestaurant_Insert_Top10
(
  @thrudate Datetime = Null
)
AS
SET NOCOUNT ON
set transaction isolation level read uncommitted


BEGIN TRANSACTION

DELETE FROM RestaurantTopList

Declare @rowlist int, @fromdate datetime, @i int --, @header nvarchar(50),

Select @i = 1

If @thrudate is null
	Begin
	Select @thrudate = Cast(convert(nvarchar, getdate(), 101) as datetime) --get request(current) date to range
	End

Select MetroAreaID from MetroArea
Select @rowlist = @@RowCount
Select @fromdate = dateadd(d,-7,Cast(@thrudate as datetime)) --get request date from range

CREATE TABLE #RowNumber (RowNumber int IDENTITY (1, 1)
                        ,rest_ID int
                        ,resos int )

While @i <= @rowlist
BEGIN

INSERT INTO #RowNumber (rest_ID,resos)
Select top 10 rt.RID as rest_ID
,count(r.ResID) as resos

From       Reservation r
inner join Restaurant rt 
on         r.RID = rt.RID
inner join Neighborhood n 
on         rt.NeighborhoodID = n.NeighborhoodID
inner join MetroArea MetroArea 
on         n.MetroAreaID = MetroArea.MetroAreaID
left outer join Caller OTCaller 
on         r.CallerID = OTCaller.CallerID
Where      n.MetroAreaID = @i 
and        r.DateMade between @fromdate and @thrudate 
and        coalesce(OTCaller.PositionID,0) <> 2 
and        MetroArea.toptenlist = 1 
and        RStateID not in  (3,4,8,9,10)
group by   rt.RID
Order by   count(r.ResID) desc

Insert Into RestaurantTopList
	(Rank, RID,Resos)
SELECT RowNumber as Rank
,rest_ID as RID
,resos as Resos
FROM #RowNumber r 
ORDER BY RowNumber

Truncate Table #RowNumber

Select @i = @i + 1
END

DROP TABLE #RowNumber

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO



GRANT EXECUTE ON [ReportRestaurant_Insert_Top10] TO ExecuteOnlyRole

GO
