
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Referrer_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Referrer_Add]
GO






CREATE PROCEDURE dbo.Admin_Referrer_Add
 (
  @Name nvarchar(255),
 @SuppressAlternative int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

INSERT INTO Referrer
 (
  ReferrerName,
  SuppressAlternative 
 )
VALUES
 (
  @Name,
  @SuppressAlternative
 )
if (@@ERROR <> 0)
	goto general_error

select scope_identity()as ReferrerId

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_Referrer_Add] TO ExecuteOnlyRole

GO
