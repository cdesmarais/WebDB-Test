if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_InStoreCoversXDaysAgo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_InStoreCoversXDaysAgo]
GO

CREATE PROCEDURE dbo.Daily_InStoreCoversXDaysAgo

(
@rptID int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @YestTotalCovers int

select @YestTotalCovers = sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)  
from Reservation 
inner join Restaurant r on r.RID = Reservation.RID 
inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
where RStateID in(1,2,5,6,7) and 
datediff(d,Reservation.ShiftDate,getdate() - @strDateOffset) =0 
and n.metroareaid <> 1

select     @YestTotalCovers = coalesce(@YestTotalCovers , 0)

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = '/' + cast(@YestTotalCovers as nvarchar(20)) + @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_InStoreCoversXDaysAgo] TO ExecuteOnlyRole

GO
