
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateUploadTransactionLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateUploadTransactionLog]

GO
CREATE PROCEDURE dbo.DNUpdateUploadTransactionLog

(
            @transactionID int,
            @initiateDate datetime,
            @userID int,
            @statusid int
)

As

update uploadtransactionlog 
set initiatedate = isnull(@initiatedate,initiatedate),  
laststatusupdate = getdate(),                  
userID =   isnull(@userID,userID),
statusid = isnull(@statusid,statusid)
where transactionid = @transactionid

GO
  GRANT EXECUTE ON [DNUpdateUploadTransactionLog] TO ExecuteOnlyRole

 

GO

