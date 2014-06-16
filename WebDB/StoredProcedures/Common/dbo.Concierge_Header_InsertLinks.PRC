if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Header_InsertLinks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Header_InsertLinks]
GO



CREATE PROCEDURE dbo.Concierge_Header_InsertLinks
 (
  @Header_ID int,
  @linkname nvarchar(255),
  @link nvarchar(255)
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

INSERT INTO CallerHeaderLinks (LinkName,Link,HeaderID) VALUES ( @linkname,@link,@Header_ID )
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Header_InsertLinks] TO ExecuteOnlyRole

GO
