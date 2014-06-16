if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SetEmailPreferences2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SetEmailPreferences2]
GO

-- User_SetEmailPreferences2:

-- Wrapper proc that calls either User_SetEmailPreferences_Cust or User_SetEmailPreferences_Caller depending on @IsCallerOrAdmin
-- Note:  This proc was split into 2 child procs as an optimization. This enables query engine to prepare static execution plan
-- using either CustID index or CallerID index, depending on the proc.

-- Update UserOptIn table to reflect all opted in locations for given user/newsletter type...
-- STEP 1:  Where opted-in location *does* have existing UserOptIn row, but newsletter bit is 0 [opt-out], update it.
-- STEP 2:  Where there's an existing UserOptIn row with newsletter bit 1 but which does not match any opted-in locations passed in,
--   update it by setting newletter bit to 0.
-- STEP 3:  Where opted-in location does not have existing UserOptIn row, create it with newsletter bit set to 1.

-- OptedInLocationsDataSet
-- Dataset parameter contains one row for each location for which user is opted in for this type of newsletter.
-- By implication, locations that are absent from dataset are locations for which user is opted-out for newsletter. 
-- Dataset conforms to a UDT, defined as:
/*
CREATE TYPE dbo.OptedInLocationsDataSet AS TABLE 
      ( 
            MetroAreaID		INT,
            MacroID			INT,
            NeighborhoodID	INT
      ); */

CREATE PROCEDURE [dbo].User_SetEmailPreferences2
(
	@UserID int,				-- designates either customer or caller, depending on @IsCallerOrAdmin parameter
	@IsCallerOrAdmin bit,		-- indicates wheter @UserID designates caller [bit = 1] or customer [bit = 0] 
	@NewsletterID int,			-- type of newsletter, see Newsletter table [1 = "Spotlight", etc.]
	@OptedInLocationsDataSet OptedInLocationsDataSet READONLY  -- All locations for which user is opted in for this type of newsletter
)
AS

SET NOCOUNT ON

IF @IsCallerOrAdmin = 0 
	EXEC User_SetEmailPreferences_Customer @UserID, @NewsletterID, @OptedInLocationsDataSet
ELSE
	EXEC User_SetEmailPreferences_Caller @UserID, @NewsletterID, @OptedInLocationsDataSet
GO

GRANT EXECUTE ON [User_SetEmailPreferences2] TO ExecuteOnlyRole
GO