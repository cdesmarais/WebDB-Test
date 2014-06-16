if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminGetRIDNLInfo2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminGetRIDNLInfo2]
GO

CREATE PROCEDURE dbo.AdminGetRIDNLInfo2
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  DISTINCT(n.RID), 
		ISNULL(v.NLData1, '') as SingleRoot, 
		ISNULL(v.NLData2, '') as City, 
		ISNULL(v.NLURL, '') as SingleURL, 
		ISNULL(rp.NLData1, '') as RestProfileRoot, 
		ISNULL(rp.NLURL, '') as RestProfileURL, 
		ISNULL(l.UpdatedBy, 'DBScript') as UpdatedBy, 
		COALESCE(l.UpdatedDT, 
		  CASE 
		    WHEN rp.DataLastModifiedDt is null THEN ISNULL(v.DataLastModifiedDt, '')
		    WHEN v.DataLastModifiedDt is null THEN rp.DataLastModifiedDt
		    WHEN rp.DataLastModifiedDt > v.DataLastModifiedDt THEN rp.DataLastModifiedDt
		    ELSE v.DataLastModifiedDt
		  END 
		) as UpdatedDT
FROM	NLURLVw  n
LEFT JOIN (
    SELECT RID, NLData1, NLData2, NLURL, DataLastModifiedDt
	FROM dbo.NLURLVw v
	WHERE	v.NLDataID IN
	(SELECT MAX(NLDataID) FROM dbo.NLURLVw
	  WHERE NLRuleID = 1   -- Single.aspx NL Rule
	  GROUP BY RID
	)  
)v	
ON n.RID = v.RID
LEFT JOIN  (
	SELECT RID, NLData1, NLURL, DataLastModifiedDt
	FROM dbo.NLURLVW 
	WHERE  NLDataID in
	(
	  SELECT MAX(NLDataID) FROM dbo.NLURLVw
	  WHERE NLRuleID = 8   -- Rest_Profile.aspx NL Rule
	  GROUP BY RID
	)
) rp
ON v.RID  = rp.RID
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
ON n.RID  = l.RID 
WHERE NLRuleID=1 OR NLRuleID=8
ORDER BY n.RID
GO

GRANT EXECUTE ON [AdminGetRIDNLInfo2] TO ExecuteOnlyRole
GO