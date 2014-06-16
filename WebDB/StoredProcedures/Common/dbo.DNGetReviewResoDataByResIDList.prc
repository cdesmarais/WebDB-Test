if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetReviewResoDataByResIDList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetReviewResoDataByResIDList]
GO

CREATE PROCEDURE dbo.DNGetReviewResoDataByResIDList
(
    @ResIDList varchar(8000)
)
AS
--- 	THIS STORED PROC IS DEPRECATED AND IS REPLACED WITH DNGetReviewResoData
---		IT WILL BE LEFT IN FOR 2010R12 AND REMOVED IN 2011R1 FOR BACKWARD COMPATIBILITY
---		DURING DEPLOYMENT OF 2010R12
---
-- The upper size limit of the list of ResIDs is 800 assuming 10 bytes per 
-- ResID (9 bytes for a 9 digit ResID + 1 for the comma)
-- It is not assumed that we will need 2 byte chars for this stored proc so
-- we're using the varchar data type
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @csv TABLE
(
	ResID INT
)

INSERT INTO @csv
SELECT * FROM dbo.fIDStrToTab(@ResIDList, ',')

-- Find the metros that we are excluding from this data fetch
select		res.ResID
		,	r.RID
		,	res.CustID
		,	r.RName as Restname
		,	n.MetroAreaID				
		,	res.ResPoints		
		,	res.ShiftDate + 2 + res.ResTime as ReservationDate
		,   res.RStateID
		,	NULL as AdminCustID --placeholder for compatibility
		,	NULL as OriginalCustID --placeholder		
from		Reservation res
inner join 	 @csv c
ON res.ResId = c.ResID
INNER JOIN RestaurantAVW r
ON res.RID = r.RID
AND res.LanguageID = r.LanguageID
INNER JOIN Neighborhood n
ON r.NeighborhoodID = n.NeighborhoodID
order by r.RID

GO


GRANT EXECUTE ON [DNGetReviewResoDataByResIDList] TO ExecuteOnlyRole

GO

