if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Header_DeleteLink]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Header_DeleteLink]
GO




CREATE PROCEDURE dbo.Admin_Concierge_Header_DeleteLink
 (
  @Link_ID int
 )
As
SET NOCOUNT ON
DELETE FROM CallerHeaderLinks
WHERE (LinkID = @Link_ID)

GO

GRANT EXECUTE ON [Admin_Concierge_Header_DeleteLink] TO ExecuteOnlyRole

GO
