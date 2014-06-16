if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNewYorkMetroRedirect]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNewYorkMetroRedirect]
GO

CREATE Procedure dbo.DNNewYorkMetroRedirect
 
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

	SELECT MetroID 
		,MacroID 
		,RedirectTo
		,NeighborhoodName
	FROM dbo.NewYorkMetroSplitRedirect

GO

GRANT EXECUTE ON [DNNewYorkMetroRedirect] TO ExecuteOnlyRole

GO
