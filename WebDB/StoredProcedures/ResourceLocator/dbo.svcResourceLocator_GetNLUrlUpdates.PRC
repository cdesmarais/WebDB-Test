if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcResourceLocator_GetNLUrlUpdates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[svcResourceLocator_GetNLUrlUpdates]
GO

/*
Return URLs for a given Rule ID that have been modified or published since a given date (typically,
the "highwater mark" of the previous execution of this query) returning only the most recently 
modified/published entry per standard URL.  
- If an URL has never been published, return the most recent modification with PublishedOrModifiedDateLocal = DataLastModifiedDt
- If an URL has been published at any time in history, ignore (do not return) unpublished modifications. 
     Instead, return the last published entry (but only if it is more recent than UpdatedSince date).
     PublishedOrModifiedDateLocal = MapFilePublishedDt
- Sort results by date published (if published) or date modified (if never published) in descending order.
- Next highwater mark = the PublishedOrModifiedDateLocal date in first row returned.
*/

CREATE PROCEDURE [dbo].[svcResourceLocator_GetNLUrlUpdates]
	@NLRuleID INT,
	@UpdatedSince DATETIME
AS
SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
    NLDataID
    ,NLRuleID
    ,NLMapKey
    ,PageName + CASE WHEN NLMapKey IS NOT NULL THEN '?' + NLMapKey END AS StandardURL
    ,NLURL
    ,PublishedOrModifiedDateLocal
    ,CASE WHEN MapFilePublishedDt IS NULL THEN 0 ELSE 1 END AS IsPublished
FROM
(
    -- In inner query, compute "Ranking" based on entire history of a given Standard URL.
    -- Per URL, rank entries based on published and modified dates, in reverse chronological order.
    -- Published dates, if present, always precede modification dates.
    -- Outer query selects only one entry per URL whose ranking = 1 (i.e, the entry with
    --    most recent published date, or, if never published, with most recent modified date).
	SELECT 
		NLDataID
		,NLRuleID
		,PageName
		,NLMapKey  
		,NLURL
		,ISNULL(MapFilePublishedDt, DataLastModifiedDt) AS PublishedOrModifiedDateLocal
		,MapFilePublishedDt
		,ROW_NUMBER() OVER(PARTITION BY PageName, NLMapKey ORDER BY MapFilePublishedDt DESC, DataLastModifiedDt DESC) AS Ranking
	FROM _NLURLVW
	WHERE 
		((@NLRuleID IS NULL) OR (NLRuleID = @NLRuleID))
) AS InnerQuery

WHERE
	((@UpdatedSince IS NULL) OR (PublishedOrModifiedDateLocal > @UpdatedSince))
	AND
	(Ranking = 1)
	
ORDER BY PublishedOrModifiedDateLocal DESC
GO

GRANT EXECUTE ON [svcResourceLocator_GetNLUrlUpdates] TO ExecuteOnlyRole
GO