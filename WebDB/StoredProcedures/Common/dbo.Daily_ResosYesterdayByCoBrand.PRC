if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosYesterdayByCoBrand]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosYesterdayByCoBrand]
GO

create proc dbo.Daily_ResosYesterdayByCoBrand
( 
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select p.PartnerName as PartnerName
	,count(ResID) as ResCount
	,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers 
	from Reservation r
	inner join Partner p
	on r.PartnerID = p.PartnerID
	inner join restaurant rt
	on r.RID = rt.RID
	inner join Neighborhood n 
	on rt.NeighborhoodID = n.NeighborhoodID
	where r.RStateID in (1,2,5,6,7)
	and r.PartnerID <> 1
	and datediff(d,r.DateMade,(getdate()-@strDateOffset)) = 0
	and n.MetroAreaID <> 1
	group by p.PartnerName 
	order by Covers desc

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Reservations yesterday by co-brand site (Covers): ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @PartnerName nvarchar(255)
	Declare @ResCount nvarchar(255)
	Declare @Covers nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @PartnerName, @ResCount, @Covers

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @PartnerName + ' : ' + @ResCount + ' (' + @Covers + ')' + @vbnewline
		
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @PartnerName, @ResCount, @Covers
	END
	CLOSE rpt_cur


GO

GRANT EXECUTE ON [Daily_ResosYesterdayByCoBrand] TO ExecuteOnlyRole

GO
