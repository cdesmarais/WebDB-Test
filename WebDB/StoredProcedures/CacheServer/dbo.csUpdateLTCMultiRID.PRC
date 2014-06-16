--$ create proc csUpdateLTCMultiRID
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csUpdateLTCMultiRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csUpdateLTCMultiRID]
GO

CREATE Procedure dbo.csUpdateLTCMultiRID
 (
  @Restaurants varchar(8000)
 )
As
	declare @rc as int
	exec @rc = procUpdateLTCMultiRID @Restaurants
	return @rc
GO

GRANT EXECUTE ON [csUpdateLTCMultiRID] TO ExecuteOnlyRole
GO
