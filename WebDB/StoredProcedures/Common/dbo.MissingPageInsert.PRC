if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MissingPageInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MissingPageInsert]
GO


CREATE PROCEDURE dbo.MissingPageInsert
(
  @QueryString nvarchar(4000),
  @Referrer nvarchar(4000)
)
AS
SET NOCOUNT ON

if (@QueryString != 'System.String[]' and @Referrer != 'System.String[]')
BEGIN
	Insert into tbl404 (QueryString,Referrer) values (@QueryString, @Referrer)
END
GO


GRANT EXECUTE ON [MissingPageInsert] TO ExecuteOnlyRole

GO
