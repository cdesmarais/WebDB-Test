if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Company_Insert_Top10]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Company_Insert_Top10]
GO

CREATE PROCEDURE dbo.Report_Company_Insert_Top10
(
  @thrudate Datetime = Null
)
AS

set transaction isolation level read uncommitted
SET NOCOUNT ON
BEGIN TRANSACTION

DELETE FROM CompanyTopList

Declare @rowlist int, @fromdate datetime, @i int --, @header nvarchar(50),

Select @i = 1

If @thrudate is null
	Begin
	Select @thrudate = Cast(convert(nvarchar, getdate(), 101) as datetime) --get request(current) date to range
	End

Select MetroAreaID from MetroAreaVW
-- where toptenlist = 1 and MetroAreaID <> 1
Select @rowlist = @@RowCount

--print @rowlist

Select @fromdate = dateadd(d,-7,Cast(@thrudate as datetime)) --get request date from range

CREATE TABLE #RowNumber (
RowNumber int IDENTITY (1, 1),
CompanyID int,
resos int )

While @i <= @rowlist
BEGIN

INSERT INTO #RowNumber (CompanyID,resos)
Select top 10 OTComp.CompanyID as CompanyID, count(r.ResID) as resos
From Reservation r
	inner join Company OTComp on r.CompanyID = OTComp.CompanyID
Where OTComp.MetroAreaID = @i and r.DateMade between @fromdate and @thrudate and RStateID not in (3,4,8,9,10)
group by OTComp.CompanyID
Order by count(r.ResID) desc

Insert Into CompanyTopList
	(Rank, CompanyID,Resos)
SELECT RowNumber as Rank, CompanyID as CompanyID, resos as Resos
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


GRANT EXECUTE ON [Report_Company_Insert_Top10] TO ExecuteOnlyRole

GO
