if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosYesterdayByPartner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosYesterdayByPartner]
GO

create proc dbo.Daily_ResosYesterdayByPartner 
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

Declare @BeginDT as datetime,
		@EndDT as Datetime

select @BeginDT = dbo.fGetDatePart(getdate()-@strDateOffset)
select @EndDT  = dbo.fGetDatePart(getdate()-@strDateOffset+1)

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select 
		Referrer.ReferrerID as PartnerID
		,Referrer.ReferrerName as PartnerName
		,count(r.ResID) as ResCount
		,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers 
	from Reservation r  
	inner join ReferrerReservationVW rr
	on r.ResID = rr.ResID 
	inner join Referrer 
	on Referrer.ReferrerID = rr.ReferrerID 
	inner join restaurant rt
	on r.RID = rt.RID   
	inner join Neighborhood n 
	on rt.NeighborhoodID = n.NeighborhoodID  
	where r.RStateID in (1,2,5,6,7) 
	and r.DateMade>=@BeginDT
	and r.DateMade<@EndDT
	and n.MetroAreaID <> 1  
	group by Referrer.ReferrerID, Referrer.ReferrerName 
	order by Covers desc

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Reservations yesterday by Partner - aka referrer (Covers): ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @PartnerID nvarchar(255)
	Declare @PartnerName nvarchar(255)
	Declare @ResCount nvarchar(255)
	Declare @Covers nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @PartnerID, @PartnerName, @ResCount, @Covers

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = '['+ @PartnerID + ']: ' + @PartnerName + ' : ' + @ResCount + ' (' + @Covers + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @PartnerID, @PartnerName, @ResCount, @Covers
	END
	CLOSE rpt_cur

GO

GRANT EXECUTE ON [Daily_ResosYesterdayByPartner] TO ExecuteOnlyRole

GO

