if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminGetRIDNLInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminGetRIDNLInfo]
GO

CREATE PROCEDURE dbo.AdminGetRIDNLInfo
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT v.RID, v.NLData1, v.NLData2, v.NLURL as SingleURL, ISNULL(l.UpdatedBy, 'DBScript') as UpdatedBy, COALESCE(l.UpdatedDT, v.DataLastModifiedDt) as UpdatedDT
FROM		dbo.NLURLVw v
LEFT JOIN  (
	SELECT RID, UpdatedBy, UpdatedDT
	FROM dbo.RestNLChangeLog 
	WHERE RestNLChangeLogID in 
	(
		SELECT MAX(RestNLChangeLogID)
		FROM dbo.RestNLChangeLog
		GROUP BY RID
	)
) l
ON v.RID  = l.RID 
WHERE		v.NLDataID IN
	(SELECT MAX(NLDataID) FROM dbo.NLURLVw
	  WHERE NLRuleID = 1   -- Single.aspx NL Rule
	  GROUP BY RID
	)   
ORDER BY v.RID
GO

GRANT EXECUTE ON [AdminGetRIDNLInfo] TO ExecuteOnlyRole
GO