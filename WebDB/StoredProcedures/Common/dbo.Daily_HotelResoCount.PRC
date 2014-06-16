if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_HotelResoCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_HotelResoCount]
GO

CREATE PROCEDURE dbo.Daily_HotelResoCount
(
@rptID int, 
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select 
		Company.CompanyName as name
		,count(Reservation.ResID) as ResoCount
	from Reservation
	inner join Caller 
	on Reservation.CallerID = Caller.CallerID
	inner join Company 
	on Caller.CompanyID = Company.CompanyID
	inner join Restaurant r 
	on Reservation.RID = r.RID
	inner join Neighborhood n 
	on r.neighborhoodid = n.neighborhoodid
	where Caller.PartnerID = 5
	and datediff(d,Reservation.DateMade,getdate()-@strDateOffset) =0
	and Reservation.RStateID in (1,2,5,6,7)
	and n.metroareaid <> 1
	group by Company.CompanyName
	order by ResoCount desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Reservations by Hotel Yesterday: ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @name nvarchar(255)
	Declare @ResoCount nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @name, @ResoCount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @name + ':  ' + @ResoCount  + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @name, @ResoCount
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_HotelResoCount] TO ExecuteOnlyRole

GO
