if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_TurnOnDIPWingsForMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_TurnOnDIPWingsForMetro]
GO

-- Turns on DIP Wings for the given metro by adding the appropriate ValueLookupIDList record
-- MMC 4/5/08

CREATE Procedure dbo.Admin_TurnOnDIPWingsForMetro
 
@MetroID int
 
As

DECLARE @ValueLookupIDForDIPWings int

-- Get the proper LookupID
SELECT	@ValueLookupIDForDIPWings = LookupID
FROM	ValueLookupMaster
WHERE	[Key] = 'DIP_WINGS_METRO'

-- Add the ValueLookup if it doesn't exist already
IF NOT EXISTS
	(
	 SELECT *
	 FROM	ValueLookupIDList
	 WHERE	LookupID = @ValueLookupIDForDIPWings AND
			ValueID = @MetroID
	)
BEGIN
	INSERT INTO ValueLookupIDList (LookupID, ValueID) VALUES (@ValueLookupIDForDIPWings, @MetroID)
END

GO

GRANT  EXECUTE  ON [dbo].[Admin_TurnOnDIPWingsForMetro]  TO [ExecuteOnlyRole]
GO
