if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosAndCoversBreakdown]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosAndCoversBreakdown]
GO

CREATE PROCEDURE dbo.Daily_ResosAndCoversBreakdown
(
@rptID int,
@strDateOffset int
)


AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @ConsumerResos as integer
declare @ConsumerCovers as integer
declare @AdminResos as integer
declare @AdminCovers as integer
declare @ConciergeResos as integer
declare @ConciergeCovers as integer
declare @AnonResos as integer
declare @AnonCovers as integer

set @ConsumerResos = 0
set @ConsumerCovers = 0 
set @AdminResos = 0
set @AdminCovers = 0
set @ConciergeResos = 0
set @ConciergeCovers = 0
set @AnonResos = 0
set @AnonCovers = 0

select @ConsumerResos = count(r.ResID),
	   @ConsumerCovers = sum(Case when(Coalesce(seatedSize,0) < 1) Then Coalesce(Partysize,0) Else seatedSize End)
 from Reservation r
inner join Customer rc on rc.CustID = r.CustID
where datediff(d,r.DateMade,getdate()-@strDateOffset) = 0
and r.RStateID in(1,2,5,6,7)
and rc.ConsumerType <> 8

select @AdminResos = count(r.ResID),
		@AdminCovers = sum(Case when(Coalesce(seatedSize,0) < 1) Then Coalesce(Partysize,0) Else seatedSize End)
from Reservation r
inner join Caller c on c.CallerID = r.CallerID
where datediff(d,r.DateMade,getdate()-@strDateOffset) = 0
and r.RStateID in(1,2,5,6,7)
and c.PositionID = 3


select @ConciergeResos = count(r.ResID),
	@ConciergeCovers = sum(Case when(Coalesce(seatedSize,0) < 1) Then Coalesce(Partysize,0) Else seatedSize End)
from Reservation r
inner join Caller c on c.CallerID = r.CallerID
where datediff(d,r.DateMade,getdate()-@strDateOffset) = 0
and r.RStateID in(1,2,5,6,7)
and c.PositionID = 2


select @AnonResos = count(r.ResID),
		@AnonCovers = sum(Case when(Coalesce(seatedSize,0) < 1) Then Coalesce(Partysize,0) Else seatedSize End)
from Reservation r
inner join Customer rc on rc.CustID = r.CustID
where datediff(d,r.DateMade,getdate()-@strDateOffset) = 0
and r.RStateID in(1,2,5,6,7)
and rc.ConsumerType = 8


select @ConsumerResos = Coalesce(@ConsumerResos,0),
		@ConsumerCovers = Coalesce(@ConsumerCovers,0), 
		@AdminResos = Coalesce(@AdminResos,0),
		@AdminCovers = Coalesce(@AdminCovers,0),
		@ConciergeResos = Coalesce(@ConciergeResos,0),
		@ConciergeCovers = Coalesce(@ConciergeCovers,0),
		@AnonResos = Coalesce(@AnonResos,0),
		@AnonCovers = Coalesce(@AnonCovers,0)

/*
select @ConsumerResos as ConsumerResos,
		@ConsumerCovers as ConsumerCovers,
		@AdminResos as AdminResos,
		@AdminCovers as AdminCovers,
		@ConciergeResos as ConciergeResos,
		@ConciergeCovers as ConciergeCovers,
		@AnonResos as AnonResos,
		@AnonCovers as AnonCovers
*/		

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set	@strReport = @vbnewline + 'Breakdown resos/covers : ' + @vbnewline +
	' Consumer: ' + cast(@ConsumerResos as nvarchar(20)) + '/' + cast(@ConsumerCovers as nvarchar(20))+ @vbnewline + 
	' Admin: ' + cast(@AdminResos as nvarchar(20)) + '/' + cast(@AdminCovers as nvarchar(20)) + @vbnewline + 
	' Concierge: ' + cast(@ConciergeResos as nvarchar(20)) + '/' + cast(@ConciergeCovers as nvarchar(20)) + @vbnewline + 
	' Anonymous: ' + cast(@AnonResos as nvarchar(20)) + '/' + cast(@AnonCovers as nvarchar(20)) + @vbnewline 

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_ResosAndCoversBreakdown] TO ExecuteOnlyRole

GO
