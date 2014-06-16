
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Referrer_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Referrer_Update]
GO






CREATE PROCEDURE dbo.Admin_Referrer_Update
 (
  @Referrer_ID int,
  @Name nvarchar(255),
  @SuppressAlternative int
 )
As
SET NOCOUNT ON
UPDATE Referrer
SET ReferrerName = @Name,
SuppressAlternative = @SuppressAlternative
WHERE ReferrerID =  @Referrer_ID

GO

GRANT EXECUTE ON [Admin_Referrer_Update] TO ExecuteOnlyRole

GO
