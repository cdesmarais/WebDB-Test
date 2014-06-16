if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SetEmailPreferences_Caller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SetEmailPreferences_Caller]
GO

-- [User_SetEmailPreferences_Caller]:
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

CREATE PROCEDURE [dbo].User_SetEmailPreferences_Caller
(
	@CallerID int,				-- designates caller
	@NewsletterID int,			-- type of newsletter, see Newsletter table [1 = "Spotlight", etc.]
	@OptedInLocationsDataSet OptedInLocationsDataSet READONLY  -- All locations for which user is opted in for this type of newsletter
)
AS

SET NOCOUNT ON

DECLARE @ProcName nvarchar(1000)
DECLARE @Action nvarchar(3000)
DECLARE @DBError int
SET @ProcName = 'User_SetEmailPreferences_Caller'

BEGIN TRAN

-- STEP 1: Update newsletter bit to 1 in each matched row
-- Inner join dataset with UserOptIn to get matched rows where bit is 0.
 
SET @Action = 'Updating existing UserOptIn rows to enable Newsletter'

UPDATE UserOptIn SET
	-- Set bit to 1 for field corresponding to NewsletterID, else 
	Spotlight =			CASE WHEN @NewsletterID = 1 THEN 1 ELSE Spotlight		END,
	Insider =			CASE WHEN @NewsletterID = 2 THEN 1 ELSE Insider			END,
	DinersChoice =		CASE WHEN @NewsletterID = 3 THEN 1 ELSE DinersChoice	END,
	NewHot =			CASE WHEN @NewsletterID = 4 THEN 1 ELSE NewHot			END,
	RestaurantWeek =	CASE WHEN @NewsletterID = 5 THEN 1 ELSE RestaurantWeek	END,
	Promotional =		CASE WHEN @NewsletterID = 6 THEN 1 ELSE Promotional		END,
	Product =			CASE WHEN @NewsletterID = 7 THEN 1 ELSE Product			END,
	UpdatedDtUTC =		GETUTCDATE()
	FROM @OptedInLocationsDataSet ds 
	WHERE 
		-- User is specified user
		UserOptIn.CallerID = @CallerID
		AND
		-- Location matches dataset's location
		-- Note: There is a UserOptIn constraint that ensures that one and only one of the location columns is non-null
		((UserOptIn.MetroAreaID IS NOT NULL AND UserOptIn.MetroAreaID = ds.MetroAreaID)
			OR
		( UserOptIn.MacroID IS NOT NULL AND UserOptIn.MacroID = ds.MacroID) 
			OR
		( UserOptIn.NeighborhoodID IS NOT NULL AND UserOptIn.NeighborhoodID = ds.NeighborhoodID))
		
		-- Newsletter is disabled
		AND 0 = CASE WHEN @NewsletterID = 1 THEN Spotlight		ELSE 0 END
		AND 0 = CASE WHEN @NewsletterID = 2 THEN Insider		ELSE 0 END
		AND 0 = CASE WHEN @NewsletterID = 3 THEN DinersChoice	ELSE 0 END
		AND 0 = CASE WHEN @NewsletterID = 4 THEN NewHot			ELSE 0 END
		AND 0 = CASE WHEN @NewsletterID = 5 THEN RestaurantWeek ELSE 0 END
		AND 0 = CASE WHEN @NewsletterID = 6 THEN Promotional	ELSE 0 END
		AND 0 = CASE WHEN @NewsletterID = 7 THEN Product		ELSE 0 END
		

-- STEP 2: Update newsletter bit to 0 in each unmatched UserOptin row.
-- Left join UserOptIn table with dataset to find unmatched rows where newsletter is opted-in.
 
SET @Action = 'Updating existing UserOptIn rows to disable Newsletter'

UPDATE UserOptIn SET
	Spotlight =			CASE WHEN @NewsletterID = 1 THEN 0 ELSE Spotlight		END,
	Insider =			CASE WHEN @NewsletterID = 2 THEN 0 ELSE Insider			END,
	DinersChoice =		CASE WHEN @NewsletterID = 3 THEN 0 ELSE DinersChoice	END,
	NewHot =			CASE WHEN @NewsletterID = 4 THEN 0 ELSE NewHot			END,
	RestaurantWeek =	CASE WHEN @NewsletterID = 5 THEN 0 ELSE RestaurantWeek	END,
	Promotional =		CASE WHEN @NewsletterID = 6 THEN 0 ELSE Promotional		END,
	Product =			CASE WHEN @NewsletterID = 7 THEN 0 ELSE Product			END,
	UpdatedDtUTC =		GETUTCDATE()
	FROM 
	(
		-- Subquery to find unmatched UserOptIn rows
		SELECT
			uo.MetroAreaID,
			uo.MacroID,
			uo.NeighborhoodID
			FROM UserOptIn uo 
				LEFT JOIN @OptedInLocationsDataSet ds
					ON	-- Locations match
						((uo.MetroAreaID IS NOT NULL AND uo.MetroAreaID = ds.MetroAreaID)
							OR
						( uo.MacroID IS NOT NULL AND uo.MacroID = ds.MacroID) 
							OR
						( uo.NeighborhoodID IS NOT NULL AND uo.NeighborhoodID = ds.NeighborhoodID))
			WHERE 
				-- User is specified user
				uo.CallerID = @CallerID

				-- Newsletter is opted-in
				AND 1 = CASE WHEN @NewsletterID = 1 THEN uo.Spotlight		ELSE 1 END
				AND 1 = CASE WHEN @NewsletterID = 2 THEN uo.Insider			ELSE 1 END
				AND 1 = CASE WHEN @NewsletterID = 3 THEN uo.DinersChoice	ELSE 1 END
				AND 1 = CASE WHEN @NewsletterID = 4 THEN uo.NewHot			ELSE 1 END
				AND 1 = CASE WHEN @NewsletterID = 5 THEN uo.RestaurantWeek	ELSE 1 END
				AND 1 = CASE WHEN @NewsletterID = 6 THEN uo.Promotional		ELSE 1 END
				AND 1 = CASE WHEN @NewsletterID = 7 THEN uo.Product			ELSE 1 END
				
				-- Left join found no match in dataset
				AND ds.MetroAreaID IS NULL
				AND ds.MacroID IS NULL
				AND ds.NeighborhoodID IS NULL
				
	) AS UnmatchedUserOptIn
	WHERE 
		-- Row-to-update corresponds to row in subquery:
		-- User is specified user
		UserOptIn.CallerID = @CallerID
		AND
		-- Location matches subquery row's location
		((UserOptIn.MetroAreaID IS NOT NULL AND UserOptIn.MetroAreaID = UnmatchedUserOptin.MetroAreaID)
			OR
		( UserOptIn.MacroID IS NOT NULL AND UserOptIn.MacroID = UnmatchedUserOptin.MacroID) 
			OR
		( UserOptIn.NeighborhoodID IS NOT NULL AND UserOptIn.NeighborhoodID = UnmatchedUserOptin.NeighborhoodID))


-- STEP 3: Insert new row for each unmatched location.
-- Left join dataset with UserOptIn to get unmatched locations. 
 
SET @Action = 'Inserting new UserOptIn rows for locations not yet present'

INSERT INTO UserOptIn 
	(CustID, CallerID, 
		MetroAreaID, MacroID, NeighborhoodID,
		Spotlight, Insider, DinersChoice, NewHot, RestaurantWeek, Promotional, Product,
		UpdatedDtUTC)
SELECT
	NULL,
	@CallerID,
	ds.MetroAreaID,
	ds.MacroID,
	ds.NeighborhoodID,
	CASE WHEN @NewsletterID = 1 THEN 1 ELSE 0 END,
	CASE WHEN @NewsletterID = 2 THEN 1 ELSE 0 END,
	CASE WHEN @NewsletterID = 3 THEN 1 ELSE 0 END,
	CASE WHEN @NewsletterID = 4 THEN 1 ELSE 0 END,
	CASE WHEN @NewsletterID = 5 THEN 1 ELSE 0 END,
	CASE WHEN @NewsletterID = 6 THEN 1 ELSE 0 END,
	CASE WHEN @NewsletterID = 7 THEN 1 ELSE 0 END,
	GETUTCDATE()
	FROM @OptedInLocationsDataSet ds
		LEFT JOIN UserOptIn uo
			ON	-- Row's user is specified user
				uo.CallerID = @CallerID
				AND
				-- Row's location matches dataset's location
				((uo.MetroAreaID IS NOT NULL AND uo.MetroAreaID = ds.MetroAreaID)
					OR
				( uo.MacroID IS NOT NULL AND uo.MacroID = ds.MacroID) 
					OR
				( uo.NeighborhoodID IS NOT NULL AND uo.NeighborhoodID = ds.NeighborhoodID))
				
	WHERE uo.UpdatedDtUTC IS NULL  -- Left join found no match in UserOptin table


SET @DBError = @@ERROR
IF @DBError <> 0
	GOTO general_error

COMMIT TRAN
RETURN(0)

general_error:
	ROLLBACK TRANSACTION
	EXEC procLogProcedureError 1, @ProcName, @Action, @DBError
	RETURN(0)
GO


GRANT EXECUTE ON [User_SetEmailPreferences_Caller] TO ExecuteOnlyRole
GO