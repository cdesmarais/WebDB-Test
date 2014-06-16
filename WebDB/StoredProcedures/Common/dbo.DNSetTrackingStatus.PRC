if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSetTrackingStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSetTrackingStatus]
GO



CREATE PROCEDURE dbo.DNSetTrackingStatus
 (
  @RID int,
  @Track int
 )
As
SET NOCOUNT ON

update erbrestaurant set Track = @Track where RID = @RID
GO


GRANT EXECUTE ON [DNSetTrackingStatus] TO ExecuteOnlyRole

GO
