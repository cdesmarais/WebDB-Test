if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNClearTrackingInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNClearTrackingInfo]
GO



CREATE PROCEDURE dbo.DNClearTrackingInfo
 (
  @RID int
 )
As
SET NOCOUNT ON

--*******************************
--** This is a stub proc. It only exists beacuase some middle tier components still call it.
--*******************************
--Delete erbupdatelog from erbupdatelog where rid = @RID 

--Delete from erbcommunicationlog where rid = @RID 

--Delete erbpinglog from erbpinglog where rid = @RID
GO


GRANT EXECUTE ON [DNClearTrackingInfo] TO ExecuteOnlyRole

GO
