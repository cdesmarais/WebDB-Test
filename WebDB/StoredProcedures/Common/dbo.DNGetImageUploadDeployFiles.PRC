
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetImageUploadDeployFiles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetImageUploadDeployFiles]

GO
 
CREATE PROCEDURE dbo.DNGetImageUploadDeployFiles
As
SET NOCOUNT ON

--we want to return all the rows where status is not COMPLETE, which is the statusid of 5 in the imguploadstatus table

select transactionid, email, initiatedate
from uploadtransactionlog
inner join adminVW
on user_id = userid
where statusid not in (4,5) and UploadServer = Host_Name()
order by InitiateDate

GO
 GRANT EXECUTE ON [DNGetImageUploadDeployFiles] TO ExecuteOnlyRole

 

GO

