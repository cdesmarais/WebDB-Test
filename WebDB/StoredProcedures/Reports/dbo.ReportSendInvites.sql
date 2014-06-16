----  TT 42949   .. Count of Instances of Invites sent over a time period

declare @StartDate datetime = '2010-11-01' 
declare @Enddate  datetime = '2010-11-07'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Create Table #TempInvite
( 
	ID			int,
	resID		int
)

INSERT INTO #TempInvite 
	SELECT  o.OutBoundEmailID ,
			(
			CASE 
			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 10)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 10) AS INT)

			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 9)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 9) AS INT)

			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 8)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 8) AS INT)

			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 7)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 7) AS INT)

			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 6)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 6) AS INT)

			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 5)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 5) AS INT)

			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 4)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 4) AS INT)

			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 3)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 3) AS INT)
		
			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 2)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 2) AS INT)
			
			WHEN ISNUMERIC(substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 1)) > 0
			THEN CAST (substring(EmailBody, PATINDEX('%resid=%',o.EmailBody) + 6, 1) AS INT)
			ELSE 0
			END
			)
	FROM WebLogDB..OutBoundEmail  o
	WHERE  (o.EmailSource = 'view::btnSendInvite_Click'
			or o.EmailSource = 'invite::btnSendInvite_Click'  
			or o.EmailSource like 'EmailManager::Email%Invite')
			AND o.EmailDateTs between @StartDate and @Enddate
			AND PATINDEX('%resid=%', o.EmailBody) <> 0
			
SELECT COUNT(*)  AS [Total Invites],
	   SUM (CASE WHEN r.BillingType = 'RestRefReso'  
	   THEN 1  
	   ELSE 0  END) AS  [RestRef Invites],
	   SUM (CASE WHEN r.BillingType <> 'RestRefReso'  
	   THEN 1   
	   ELSE 0  END) AS  [Other Invites] 
from ReservationVW r
where r.ResID in 
   (select distinct t.resID as ResID  from #TempInvite t)
   
drop table #TempInvite