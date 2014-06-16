if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procExtractUserVIPStatusReportToBV]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procExtractUserVIPStatusReportToBV]
go

Create procedure dbo.procExtractUserVIPStatusReportToBV

as

Declare @LastExtractedReportDate datetime,
		@EmailBody varchar(4000),
		@EmailHeader varchar(30),
		@CurrentReportDate datetime,
		@UserID int,
		@LastUpdated datetime

Set @CurrentReportDate = null

Select top 1 @LastExtractedReportDate = ReportExtractDate
FROM UserVIPStatusReportToBVLog
order by ReportExtractDate desc

set @EmailHeader = 'UserIDs converted to VIP:'+ char(13) + char(10)
Set @EmailBody = ''

Begin Transaction

Declare cVIP CURSOR READ_ONLY 
FOR
SELECT UserID, LastUpdated
from 
(
	Select custID as UserID, max(ConvertDate) as LastUpdated
	from ConsumerTypeConvertLog
	where NewConsumerTypeID in (4, 5)
	AND custID is not null
	AND ConvertDate > @LastExtractedReportDate
	group by custID
	
	UNION 
	
	Select cc.CustID as UserID, max(cn.ConvertDate)as LastUpdated
	from ConsumerTypeConvertLog cn
	inner join CallerCustomer cc
	ON cn.callerID = cc.CallerID AND cc.IsAdmin = 1
	where cn.NewConsumerTypeID in (4, 5)
	AND cn.CallerID is not null
	AND ConvertDate > @LastExtractedReportDate
	group by cc.CustID
	
) ConvertLog
order by LastUpdated

Open cVIP

FETCH NEXT FROM cVIP INTO @UserID, @LastUpdated

WHILE @@FETCH_STATUS = 0
BEGIN
	if(LEN(@EmailBody) + LEN(@UserID) > 3970)
	Begin
		
		if(@CurrentReportDate IS NOT NULL AND @EmailBody <> '') -- last updated date of user record extracted for BV
		Begin
			insert into UserVIPStatusReportToBVLog (ReportExtractDate, EmailReportText) values (@CurrentReportDate, @EmailBody)

			if (@@error <> 0)  goto Report_Error

			Set @EmailBody = @EmailHeader + @EmailBody

			--send email 
			exec master..sp_send_cdosysmail 
				 @From = 'webdev@opentable.com'
				,@To = 'VIPUpdatesForRR@opentable.com'
				,@Subject = 'User VIP Status Report for Bazaar Voice.'
				,@Body = @EmailBody
		
			Set @EmailBody = ''
			Set @CurrentReportDate = null
		End
	End
	
	Set @EmailBody = @EmailBody + cast(@UserID as varchar) + ','
	Set @CurrentReportDate = @LastUpdated		
	
	FETCH NEXT
	FROM cVIP INTO @UserID, @LastUpdated
END
CLOSE cVIP
DEALLOCATE cVIP


--insert entry into log table with most recent extracted date from the report.
if(@CurrentReportDate IS NOT NULL AND @EmailBody <> '') -- last updated date of user record extracted for BV
Begin
	insert into UserVIPStatusReportToBVLog (ReportExtractDate, EmailReportText) values (@CurrentReportDate, @EmailBody)

	if (@@error <> 0)  goto Report_Error
	
	Set @EmailBody = @EmailHeader + @EmailBody

			--send email 
			exec master..sp_send_cdosysmail 
				 @From = 'webdev@opentable.com'
				,@To = 'VIPUpdatesForRR@opentable.com'
				,@Subject = 'User VIP Status Report for Bazaar Voice.'
				,@Body = @EmailBody
End

if @@error != 0  goto Report_Error

--Delete old records from log table.(less than one month old data)
Delete from UserVIPStatusReportToBVLog where ReportExtractDate < DateAdd(m, -2, getdate())

if @@error != 0  goto Report_Error

Commit Transaction
Return (0)

Report_Error:
Rollback transaction
RAISERROR('Error generating User VIP Status Report.',16,1)
RETURN(1)

go
GRANT EXECUTE ON [procExtractUserVIPStatusReportToBV] TO ExecuteOnlyRole

GO
