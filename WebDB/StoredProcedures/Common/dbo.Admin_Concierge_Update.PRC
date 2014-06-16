if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Update]
GO

CREATE PROCEDURE dbo.Admin_Concierge_Update

(
  @UserID int,
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @login nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @DefaultGeoID int,
  @HotelID int,
  @PositionID int,
  @PartnerID int
 )

AS
SET NOCOUNT ON

BEGIN TRANSACTION
Update Caller set 
FName = @FirstName,
LName = @LastName,
EMail = @Email,
metroareaid = @DefaultGeoID,
CompanyID = @HotelID,
PositionID = @PositionID,
LoginName = @login,
PartnerID = @PartnerID
where CallerID = @UserID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_Concierge_Update] TO ExecuteOnlyRole

GO
