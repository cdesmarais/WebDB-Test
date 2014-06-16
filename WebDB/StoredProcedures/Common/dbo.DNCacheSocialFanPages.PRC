if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheSocialFanPages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheSocialFanPages]
GO

CREATE PROCEDURE [dbo].[DNCacheSocialFanPages]
AS

SELECT *
  FROM [dbo].[SocialFanPage]

GO

GRANT EXECUTE ON [dbo].[DNCacheSocialFanPages] TO ExecuteOnlyRole

GO

