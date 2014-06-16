if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Header_UpdateLink]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Header_UpdateLink]
GO




CREATE PROCEDURE dbo.Admin_Concierge_Header_UpdateLink
 (
  @Name nvarchar(255),
  @Link nvarchar(255),
  @Link_ID int
 )
As
SET NOCOUNT ON
UPDATE CallerHeaderLinks
SET LinkName = @Name,Link = @Link 
WHERE LinkID =  @Link_ID

GO

GRANT EXECUTE ON [Admin_Concierge_Header_UpdateLink] TO ExecuteOnlyRole

GO
