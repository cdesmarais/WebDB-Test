if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLUpdateMapStatusToGenerated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLUpdateMapStatusToGenerated]
GO

CREATE PROCEDURE dbo.DNNLUpdateMapStatusToGenerated
(
  @ServerIPAddress	 NVARCHAR(50),
  @InstanceName 	 NVARCHAR(100),
  @MapFileGenDate   datetime
)
AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @SiteTypeID  int, @ServerID int, @Result int
	
	SELECT @ServerID = ServerID
	FROM [dbo].[Server]
	WHERE IPAddress = @ServerIPAddress

	SELECT @SiteTypeID = SiteTypeID
	FROM [dbo].[SiteType]
	WHERE Instance = @InstanceName

    INSERT INTO [dbo].[MapFileStatus] (
			ServerID,
			SiteTypeID,
			GeneratedDT
		)
		VALUES
		(
			@ServerID,
			@SiteTypeID,
			@MapFileGenDate
		)
		
	SELECT @Result = @@ERROR
GO

GRANT EXECUTE ON [DNNLUpdateMapStatusToGenerated] TO ExecuteOnlyRole
GO