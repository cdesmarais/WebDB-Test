if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheDiningStyle]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheDiningStyle]
GO




CREATE PROCEDURE dbo.DNCacheDiningStyle
As

SET NOCOUNT ON


SELECT 	[DiningStyleID], 
		[LanguageID], 
		DiningStyle		
FROM 	[DiningStyleVW]

GO


GRANT EXECUTE ON [DNCacheDiningStyle] TO ExecuteOnlyRole

GO