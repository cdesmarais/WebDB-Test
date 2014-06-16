IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PartnerAppToUserInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PartnerAppToUserInsert]
GO

CREATE PROCEDURE [dbo].[PartnerAppToUserInsert]
(
	@UserID int,
	@PartnerID int,
	@IsAdmin bit
)
AS

if (@IsAdmin = 1)
Begin
	if not exists (select * from [PartnerAppToCaller] p 
		where p.CallerID = @UserID and p.PartnerID = @PartnerID)
	Begin
		INSERT INTO [PartnerAppToCaller]
				   ([CallerID]
				   ,[PartnerID]
				   ,[CreateDateUtc])
			 VALUES
				   (@UserID
				   ,@PartnerID
				   ,GetUtcDate())
	End
End
else
Begin
	if not exists (select * from [PartnerAppToCustomer] p 
		where p.CustID = @UserID and p.PartnerID = @PartnerID)
	Begin
		INSERT INTO [PartnerAppToCustomer]
				   ([CustID]
				   ,[PartnerID]
				   ,[CreateDateUtc])
			 VALUES
				   (@UserID
				   ,@PartnerID
				   ,GetUtcDate())
	End
End
GO

GRANT EXECUTE ON [dbo].[PartnerAppToUserInsert] TO ExecuteOnlyRole

GO
