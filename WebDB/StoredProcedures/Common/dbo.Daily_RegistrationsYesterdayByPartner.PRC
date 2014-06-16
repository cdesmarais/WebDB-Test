if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_RegistrationsYesterdayByPartner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_RegistrationsYesterdayByPartner]
GO

create proc dbo.Daily_RegistrationsYesterdayByPartner
(
@rptID			int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	Select X.PartnerName,
		   Sum(X.UserCount) UserCount
	from
	(select Referrer.ReferrerName as PartnerName
		,count(Customer.CustID) as UserCount 
	from Customer 
	inner join ReferrerRegistration 
	on ReferrerRegistration.CustID = Customer.CustID 
	inner join Referrer 
	on Referrer.ReferrerID = ReferrerRegistration.ReferrerID 
	where Customer.email not like '%@opentable.com' 
	and datediff(d,Customer.CreateDate,getdate()- @strDateOffset) = 0  
	and Customer.MetroAreaID <> 1  
	group by Referrer.ReferrerName 
	UNION ALL (
	select Referrer.ReferrerName as PartnerName
		,count(caller.CallerID) as UserCount 
	from Caller
	inner join ReferrerRegistration 
	on ReferrerRegistration.CallerID = Caller.CallerID 
	inner join Referrer 
	on Referrer.ReferrerID = ReferrerRegistration.ReferrerID 
	where Caller.email not like '%@opentable.com' 
	and datediff(d,Caller.CreateDate,getdate()- @strDateOffset) = 0  
	and Caller.MetroAreaID <> 1  
	group by Referrer.ReferrerName ))X
	group by X.PartnerName
	order by UserCount desc


--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Registrations Yesterday by partner - aka referrer : ' + @vbnewline
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

GRANT EXECUTE ON [Daily_RegistrationsYesterdayByPartner] TO ExecuteOnlyRole

GO
