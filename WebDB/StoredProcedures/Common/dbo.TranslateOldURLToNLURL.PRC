if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TranslateOldURLToNLURL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[TranslateOldURLToNLURL]
GO

CREATE PROCEDURE [dbo].[TranslateOldURLToNLURL]
(
  @OldURL nvarchar(255)
)
AS
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TOP 1 NLURL
from		dbo.NLURLVW
where		OldURL = @OldURL

GO

GRANT EXECUTE ON [TranslateOldURLToNLURL] TO ExecuteOnlyRole
GO
