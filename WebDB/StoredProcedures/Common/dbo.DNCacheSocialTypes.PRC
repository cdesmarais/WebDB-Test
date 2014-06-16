if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheSocialTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheSocialTypes]
GO

CREATE PROCEDURE dbo.DNCacheSocialTypes
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT  
		SocialTypeID 
		,Name
		,APIKey
		,SecretKey
		,ApplicationID
FROM	SocialType

GO


GRANT EXECUTE ON [DNCacheSocialTypes] TO ExecuteOnlyRole

GO
