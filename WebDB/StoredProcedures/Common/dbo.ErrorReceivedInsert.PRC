if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ErrorReceivedInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ErrorReceivedInsert]
GO



CREATE PROCEDURE dbo.ErrorReceivedInsert
(
  @QueryString nvarchar(4000),
  @Referrer nvarchar(4000)
)
AS
SET NOCOUNT ON

Insert into tbl500 (QueryString,Referrer) values (@QueryString, @Referrer)
GO


GRANT EXECUTE ON [ErrorReceivedInsert] TO ExecuteOnlyRole

GO
