if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_TurnOffDIPWingsForAllMetros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_TurnOffDIPWingsForAllMetros]
GO

-- Turns off DIP Wings for all metros
-- MMC 4/5/08

CREATE Procedure dbo.Admin_TurnOffDIPWingsForAllMetros
 
As

DECLARE @ValueLookupIDForDIPWings int

-- Get the proper LookupID
SELECT	@ValueLookupIDForDIPWings = LookupID
FROM	ValueLookupMaster
WHERE	[Key] = 'DIP_WINGS_METRO'

-- Add the ValueLookup if it doesn't exist already
IF EXISTS
	(
	 SELECT *
	 FROM	ValueLookupIDList
	 WHERE	LookupID = @ValueLookupIDForDIPWings
	)
BEGIN
	DELETE ValueLookupIDList 
	WHERE	LookupID = @ValueLookupIDForDIPWings
END

GO

GRANT  EXECUTE  ON [dbo].[Admin_TurnOffDIPWingsForAllMetros]  TO [ExecuteOnlyRole]
GO
