if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosTotalByPartner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosTotalByPartner]
GO

create proc dbo.Daily_ResosTotalByPartner 
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select rr.ReferrerName as PartnerName
		,count(r.ResID) as ResCount
		,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers 
	from Reservation r  
	inner join ReferrerReservationVW rrs
	on r.ResID = rrs.ResID 
	inner join Referrer rr
	on rr.ReferrerID = rrs.ReferrerID 
	inner join restaurant rt
	on r.RID = rt.RID   
	inner join Neighborhood n 
	on rt.NeighborhoodID = n.NeighborhoodID  
	where r.RStateID in (1,2,5,6,7) 
	and r.DateMade < getdate() - @strDateOffset
	and n.MetroAreaID <> 1  
	group by rr.ReferrerName 
	order by Covers desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Total Reservations by partner - aka referrer (Covers): ' + @vbnewline
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

GRANT EXECUTE ON [Daily_ResosTotalByPartner] TO ExecuteOnlyRole

GO
