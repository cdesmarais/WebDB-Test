if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_RegistrationsTotalByPartner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_RegistrationsTotalByPartner]
GO

create proc dbo.Daily_RegistrationsTotalByPartner
(
@rptID int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	Select X.PartnerName,
		   Sum(X.UserCount) UserCount
	from 
	(select r.ReferrerName as PartnerName
		,count(c.CustID) as UserCount 
	from Customer c
	inner join ReferrerRegistration rr
	on rr.CustID = c.CustID 
	inner join Referrer r
	on r.ReferrerID = rr.ReferrerID 
	where c.Email not like '%@opentable.com' 
	and c.MetroAreaID <> 1  
	group by r.ReferrerName 
	UNION ALL (
	select r.ReferrerName as PartnerName
		,count(c.CallerID) as UserCount 
	from Caller c
	inner join ReferrerRegistration rr
	on rr.CallerID = c.CallerID 
	inner join Referrer r
	on r.ReferrerID = rr.ReferrerID 
	where c.Email not like '%@opentable.com' 
	and c.MetroAreaID <> 1  
	group by r.ReferrerName))X
	Group by X.PartnerName
	order by UserCount desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Total Registrations by partner - aka referrer : ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @PartnerName nvarchar(255)
	Declare @UserCount nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @PartnerName, @UserCount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @PartnerName + ' : ' + @UserCount + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @PartnerName, @UserCount
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_RegistrationsTotalByPartner] TO ExecuteOnlyRole

GO
