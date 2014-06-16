
 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCreateUploadTransaction]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCreateUploadTransaction]

GO
CREATE PROCEDURE dbo.DNCreateUploadTransaction
(
            @userID int, 
            @statusID int 
)
  

As

 
insert into uploadtransactionlog (initiatedate,laststatusupdate,userid,statusid,UploadServer)
VALUES (getdate(),getdate(),@userID,@statusid,Host_Name())
SELECT scope_identity() AS 'Identity'

GO

 GRANT EXECUTE ON [DNCreateUploadTransaction] TO ExecuteOnlyRole

 

GO

