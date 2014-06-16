if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLIsMapGenerated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLIsMapGenerated]
GO

CREATE PROCEDURE dbo.DNNLIsMapGenerated
(
  @ServerIPAddress	 NVARCHAR(50),
  @InstanceName 	 NVARCHAR(100),
  @MapFileGenDate   datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @SiteTypeID  int, @ServerID int

SELECT @ServerID = ServerID
FROM [dbo].[Server]
WHERE IPAddress = @ServerIPAddress

SELECT @SiteTypeID = SiteTypeID
FROM [dbo].[SiteType]
WHERE Instance = @InstanceName


SELECT Count(*)
FROM [dbo].[MapFileStatus]
WHERE [ServerID] = @ServerID AND [SiteTypeID] = @SiteTypeID
AND [GeneratedDT] = @MapFileGenDate
GO

GRANT EXECUTE ON [DNNLIsMapGenerated] TO ExecuteOnlyRole
GO