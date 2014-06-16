

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTRGetNLURLDataForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTRGetNLURLDataForRID]
GO

CREATE PROCEDURE dbo.OTRGetNLURLDataForRID
	@RID int 
AS
/*
	Procedure gets the NLURL data for specific restaurant. Owned by India Team
*/

	SELECT 
		RID
		,ISNULL(v.NLData1, '') as SingleRoot
		,ISNULL(v.NLData2, '') as City
		,ISNULL(v.NLURL, '') as SingleURL
	FROM 
		NLURLVw v
	WHERE
		v.NLDataID IN
		(
			SELECT
				MAX(NLDataID) 
			FROM
				dbo.NLURLVw
			WHERE
				NLRuleID = 1   -- Single.aspx NL Rule
			GROUP BY RID
		)
		and NLRuleID = 1
		and RID = @RID 
GO

GRANT EXECUTE ON [OTRGetNLURLDataForRID] TO ExecuteOnlyRole
GO
