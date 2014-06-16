if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdatePartnerIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdatePartnerIP]
GO




CREATE PROCEDURE dbo.Admin_UpdatePartnerIP
  @ipaddress nvarchar(30),
  @partnerID int,
  @orig_ipaddress nvarchar(30)
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION MyTran
if Not Exists(Select PartnerID From PartnerIPs Where IPAddress = @orig_ipaddress) Goto no_ip

    Update PartnerIPs
    Set IPAddress = @ipaddress,
          PartnerID = @partnerID
    Where IPAddress = @orig_ipaddress
    IF (@@ERROR <> 0) Goto general_error
    COMMIT TRAN
    RETURN(0)

general_error:
ROLLBACK TRANSACTION MyTran
RAISERROR('general error',17,1)
RETURN(2)

no_ip:
ROLLBACK TRANSACTION MyTran
RAISERROR('The IP Address you are updating could not be found.',17,1)
RETURN(1)
GO

GRANT EXECUTE ON [Admin_UpdatePartnerIP] TO ExecuteOnlyRole

GO
