if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_LargePartyResoInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_LargePartyResoInfo]
GO

CREATE proc dbo.Daily_LargePartyResoInfo
@rptID int
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select     r.RName
			,' (' + ma.MetroAreaName  + ') ' as City
			,count(rs.ResID) as ResoCount
			,' (' + convert(nvarchar, sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)) + ') ' as CoverCount
			,left(convert(nvarchar, avg(rs.PartySize * 1.0)), 3) as PerResoAverage
	from       reservation rs
	inner join restaurantVW r
	on         rs.RID = r.RID
	inner join neighborhoodAVW n
	on         r.NeighborhoodID = n.NeighborhoodID 
	and		   r.LanguageID = n.LanguageID
	inner join MetroAreaAVW ma
	on         n.MetroAreaID = ma.MetroAreaID
	and		   r.LanguageID = ma.LanguageID
	where      n.MetroAreaID <> 1
	and        rs.LargeParty = 1
	and        rs.RStateID in(1,2,5,6,7)
	group by   r.RName
			,ma.MetroAreaName

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Large Party Reso Info: (Name,city,Resos,Covers,PerResoAvg)' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @RName nvarchar(255)
	Declare @City nvarchar(255)
	Declare @ResoCount nvarchar(255)
	Declare @CoverCount nvarchar(255)
	Declare @PerResoAverage nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @RName, @City, @ResoCount, @CoverCount, @PerResoAverage

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @RName + ' ' + @City + @CoverCount + ' ' + @PerResoAverage + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @RName, @City, @ResoCount, @CoverCount, @PerResoAverage
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_LargePartyResoInfo] TO ExecuteOnlyRole

GO
