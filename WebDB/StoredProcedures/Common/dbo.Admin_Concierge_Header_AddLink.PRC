if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Header_AddLink]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Header_AddLink]
GO




CREATE PROCEDURE dbo.Admin_Concierge_Header_AddLink
 (
  @Name nvarchar(255),
  @Link nvarchar(255),
  @Header_ID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

INSERT INTO CallerHeaderLinks
 (
  LinkName,Link,HeaderID
 )
VALUES
 (
  @Name,@Link,@Header_ID
 )

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_Concierge_Header_AddLink] TO ExecuteOnlyRole

GO
