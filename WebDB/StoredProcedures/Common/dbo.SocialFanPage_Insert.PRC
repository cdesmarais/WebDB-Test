if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SocialFanPage_Insert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SocialFanPage_Insert]
GO

CREATE PROCEDURE [dbo].[SocialFanPage_Insert]
	@RID int,
	@FanPageID nvarchar(50),
	@Disabled bit
AS

INSERT INTO [dbo].[SocialFanPage]
           ([RID]
           ,[FanPageID]
           ,[Disabled])
     VALUES
           (@RID
           ,@FanPageID
           ,@Disabled)
GO

GRANT EXECUTE ON [dbo].[SocialFanPage_Insert] TO ExecuteOnlyRole

GO


