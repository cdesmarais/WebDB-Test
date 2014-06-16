if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_PromoReservations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_PromoReservations]
GO

CREATE PROCEDURE dbo.Daily_PromoReservations
(
@rptID int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	Select Code,
		count(Reservation.ResID) as Reservations,
		sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers  
	from Reservation
	inner join PromoReservations on Reservation.ResID = PromoReservations.ResID
	inner join Promos on PromoReservations.PromoID = Promos.PromoID
	inner join Restaurant r on  Reservation.RID = r.RID
	inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid
	where n.metroareaid <> 1 and RStateID not in (3,4,8,9,10)
	and Promos.Points = Reservation.ResPoints
	and datediff(d,Reservation.DateMade,(getdate()- @strDateOffset)) = 0 
	group by Code order by Covers desc


--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Promo reservations yesterday : ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @Code nvarchar(255)
	Declare @Reservations nvarchar(255)
	Declare @Covers nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @Code, @Reservations, @Covers

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @Code + ' : ' + @Reservations + ' (' + @Covers + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @Code, @Reservations, @Covers
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_PromoReservations] TO ExecuteOnlyRole

GO
