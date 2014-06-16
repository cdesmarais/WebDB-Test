if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_NewUsersByCoBrand]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_NewUsersByCoBrand]
GO

create proc dbo.Daily_NewUsersByCoBrand 
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select p.PartnerName as PartnerName
	,count(CustID) as UserCount
	,sum(cast(SendAnnouncements as int)) as OptIn  
	from Customer c
	inner join Partner p
	on p.PartnerID = c.PartnerID 
	where c.PartnerID <> 1 
	and datediff(d,c.CreateDate,(getdate()- @strDateOffset)) = 0 
	group by p.PartnerName 
	order by UserCount desc

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'New Users by co-brand site (Op-Ins in Parens): (yesterday) ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @PartnerName nvarchar(255)
	Declare @UserCount nvarchar(255)
	Declare @OptIn nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @PartnerName, @UserCount, @OptIn

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @PartnerName + ' : ' + @UserCount + ' (' + @optin + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @PartnerName, @UserCount, @OptIn
	END
	CLOSE rpt_cur

GO

GRANT EXECUTE ON [Daily_NewUsersByCoBrand] TO ExecuteOnlyRole

GO
