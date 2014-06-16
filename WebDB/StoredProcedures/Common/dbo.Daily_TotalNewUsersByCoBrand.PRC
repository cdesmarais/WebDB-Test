if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalNewUsersByCoBrand]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalNewUsersByCoBrand]
GO

create proc dbo.Daily_TotalNewUsersByCoBrand 
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
	,sum(cast(SendAnnouncements as int)) as optin  
	from Customer  
	inner join Partner p
	on p.PartnerID = Customer.PartnerID 
	where Customer.PartnerID <> 1 
	and Customer.createDate>=dbo.fGetDatePart(getdate()-(30+@strDateOffset))
	and Customer.createDate<=dbo.fGetDatePart(getdate()-(@strDateOffset))
	group by p.PartnerName 
	order by UserCount desc

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + '30 Day Trailing Users by co-brand site (Op-Ins in Parens): ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @PartnerName nvarchar(255)
	Declare @UserCount nvarchar(255)
	Declare @optin nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @PartnerName, @UserCount, @optin

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @PartnerName + ' : ' + @UserCount + ' (' + @optin + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @PartnerName, @UserCount, @optin
	END
	CLOSE rpt_cur

GO

GRANT EXECUTE ON [Daily_TotalNewUsersByCoBrand] TO ExecuteOnlyRole

GO
