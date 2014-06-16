if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_GetHotelResoCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_GetHotelResoCount]
GO

CREATE PROCEDURE dbo.Daily_GetHotelResoCount
(
@rptID int,
@strDateOffset int
)
as

set transaction isolation level read uncommitted
SET NOCOUNT ON

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select Company.CompanyName as CompanyName, 
	( ' (' + ma.MetroAreaName + ') : ' ) as MetroName
	,count(Reservation.resid) as resos
	,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers
	from reservation
	inner join caller 
	on Caller.CallerID = Reservation.CallerID 
	inner join Company 
	on Company.CompanyID = Caller.CompanyID 
	inner join MetroAreaVW ma
	on Company.MetroAreaID = ma.MetroAreaID 
	where caller.positionid = 2
	and caller.companyid not in (2,41)
	and reservation.rstateid in(1,2,5,6,7)
	and datemade>=dbo.fGetDatePart(getdate()-(30+@strDateOffset))
	and datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))
	Group by Company.CompanyName
	, ma.MetroAreaName 
	order by resos desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + '30 Day Trailing Reservations by Hotel: (resos/covers)' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @CompanyName nvarchar(255)
	Declare @MetroName nvarchar(255)
	Declare @resos nvarchar(255)
	Declare @Covers nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @CompanyName, @MetroName, @resos, @Covers

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @CompanyName + @MetroName + @resos + '(' + @Covers + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @CompanyName, @MetroName, @resos, @Covers
	END
	CLOSE rpt_cur

GO



GRANT EXECUTE ON [Daily_GetHotelResoCount] TO ExecuteOnlyRole

GO
