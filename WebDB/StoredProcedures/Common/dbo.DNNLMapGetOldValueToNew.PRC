if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetOldValueToNew]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetOldValueToNew]
GO

CREATE PROCEDURE dbo.DNNLMapGetOldValueToNew
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--****************************************
--** The use of a temp table greatly improves the performance of this query
--** using a table variable instead or a subquery does not have the same affect
--****************************************
create table #NewNLData ( NLRuleID int, NLDataID int, NLCount int)
insert into #NewNLData
		SELECT NLRuleID,MAX(NLDataID) NLDataID, COUNT(1) NLCount
		FROM NLURLVw
		WHERE (DataLastModifiedDt  <= @MapFileGenDateTime)
		GROUP BY NLRuleID,RID,MetroAreaID,MacroID,NeighborhoodID,FoodTypeID,PromoID,PrivateEventTypeID
		having COUNT(1) > 1
		
SELECT	distinct o.NLURL + ' ' + n.NLURL
FROM		dbo.NLURLVw n
LEFT JOIN	dbo.NLURLVw o
ON		n.NLRuleID = o.NLRuleID 
AND		(o.NLDataID !=  n.NLDataID) 
AND		ISNULL(n.RID, -1) = ISNULL(o.RID, -1)
AND		ISNULL(n.MetroAreaID, -1) =  ISNULL(o.MetroAreaID, -1)
AND		ISNULL(n.MacroID, -1) = ISNULL(o.MacroID, -1)
AND		ISNULL(n.NeighborhoodID, -1) = ISNULL(o.NeighborhoodID, -1)
AND		ISNULL(n.FoodTypeID, -1) = ISNULL(o.FoodTypeID, -1)
AND		ISNULL(n.PromoID, -1) = ISNULL(o.PromoID, -1)
AND		ISNULL(n.PrivateEventTypeID, -1) = ISNULL(o.PrivateEventTypeID, -1)
AND		(n.DataLastModifiedDt  <= @MapFileGenDateTime) 
inner join	#NewNLData x
on			x.NLRuleID = n.NLRuleID 
and			x.NLDataID = n.NLDataID 
order by	o.NLURL + ' ' + n.NLURL
GO

GRANT EXECUTE ON [DNNLMapGetOldValueToNew] TO ExecuteOnlyRole
GO