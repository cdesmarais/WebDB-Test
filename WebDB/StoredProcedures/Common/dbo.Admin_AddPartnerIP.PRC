if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddPartnerIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddPartnerIP]
GO




CREATE PROCEDURE dbo.Admin_AddPartnerIP
  @ipaddress nvarchar(30),
  @partnerID int
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION MyTran
if Exists(Select PartnerID From PartnerIPs Where IPAddress = @ipaddress) Goto dup_ip

    Insert Into PartnerIPs(IPAddress,PartnerID)
    Values(@ipaddress,@partnerID)
    IF (@@ERROR <> 0) Goto general_error
    COMMIT TRAN
    RETURN(0)

general_error:
ROLLBACK TRANSACTION MyTran
RAISERROR('general error',17,1)
RETURN(2)

dup_ip:
ROLLBACK TRANSACTION MyTran
RAISERROR('The IP Address you entered already exists.',17,1)
RETURN(1)

GO

GRANT EXECUTE ON [Admin_AddPartnerIP] TO ExecuteOnlyRole

GO
