if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MacroName_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MacroName_Get]
GO




CREATE PROCEDURE dbo.Admin_MacroName_Get
 (
  @Metro_Area_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	MacroID as Macro_ID
		,MacroName as Macro_ID
FROM	MacroNeighborhoodVW 
WHERE	metroareaid = @Metro_Area_ID
GO

GRANT EXECUTE ON [Admin_MacroName_Get] TO ExecuteOnlyRole

GO
