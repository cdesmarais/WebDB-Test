if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateImgUploadServerStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateImgUploadServerStatus]
GO

CREATE PROCEDURE dbo.DNUpdateImgUploadServerStatus
(
            @serverid int,
            @transactionID int
)
  
As

update Server 
set		ImageUploadTransactionID = @transactionID
where	serverid = @serverid

GO

GRANT EXECUTE ON [DNUpdateImgUploadServerStatus] TO ExecuteOnlyRole

GO
