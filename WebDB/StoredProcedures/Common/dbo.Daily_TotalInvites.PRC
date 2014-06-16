if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalInvites]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalInvites]
GO

CREATE   PROCEDURE dbo.Daily_TotalInvites
(
@rptID				int,
@strDateOffset		int
)
AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

declare @InviteCount int

SELECT @InviteCount = COUNT(re.ResID)  
FROM Reservation re
inner join Restaurant r 
on r.RID = re.RID  
inner join Neighborhood n 
on n.neighborhoodid = r.neighborhoodid   
where re.RStateID in(1,2,5,6,7)  
and re.InviteMessage IS NOT NULL 
and n.metroareaid <> 1
and (datediff(d,r.createdate,getdate()-@strDateOffset) >=0)



declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = 'Total Invitations sent: ' + cast(@InviteCount as nvarchar(20)) + @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_TotalInvites] TO ExecuteOnlyRole

GO
