IF EXISTS (SELECT *  FROM   dbo.sysobjects WHERE  id = object_id(N'[dbo].[Admin_Restaurant_RetrieveValueLookup]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[Admin_Restaurant_RetrieveValueLookup] 

GO

CREATE PROCEDURE [dbo].[Admin_Restaurant_RetrieveValueLookup]
(
	@LookupID INT, 
	@RID INT
)
AS
  SELECT	LookupID, ValueID 
  FROM		dbo.ValueLookupIDList 
  WHERE		LookupID = @LookupID
  AND		ValueID = @RID
  
GO

GRANT EXECUTE ON [Admin_Restaurant_RetrieveValueLookup] TO ExecuteOnlyRole

GO

