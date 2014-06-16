if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Get_404Redirect_Listing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Get_404Redirect_Listing]
GO

CREATE PROCEDURE dbo.Admin_Get_404Redirect_Listing
AS

Set nocount on

SELECT Custom404ID, Terms, RedirectTo, IsActive FROM Custom404
GO


GRANT EXECUTE ON [Admin_Get_404Redirect_Listing] TO ExecuteOnlyRole
GO
