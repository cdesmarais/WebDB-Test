if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Save_EmailForExport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Save_EmailForExport]
GO








CREATE Procedure dbo.Save_EmailForExport

@UserID int,
@PartnerID int = null,
@ReferrerID int = null,
@Exported bit = 0,
@IsCaller int


AS
if @ReferrerID <> 0   --insert the referrerID
BEGIN
	if not exists(Select userid from EmailUpdates where userid = @UserID and ReferrerID = @ReferrerID and IsCaller = @IsCaller)
	BEGIN
	Insert into EmailUpdates (userid,ReferrerID,Exported,IsCaller) values (@UserID,@PartnerID,@Exported,@IsCaller)
	END
END
else  --insert the partnerID
BEGIN
	if not exists(Select userid from EmailUpdates where userid = @UserID and PartnerID = @PartnerID and IsCaller = @IsCaller)
	BEGIN
	Insert into EmailUpdates (userid,PartnerID,Exported,IsCaller) values (@UserID,@PartnerID,@Exported,@IsCaller)
	END
END
GO

GRANT EXECUTE ON [Save_EmailForExport] TO ExecuteOnlyRole

GO
