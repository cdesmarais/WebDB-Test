if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheRestPromoDIPSuppression]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheRestPromoDIPSuppression]
GO

-- Returns list of exclusions for all active promos
CREATE PROCEDURE dbo.ObjectCacheRestPromoDIPSuppression
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

--********************************************
--** Return the set of restaurant partipating in active Promos
--** that should have DIP suppressed
--**
--**
--** Usage:
--** Lookup up RID, search date between BeginDate and EndDate
--** then	use SupressDIPLunch of search time is for lunch
--			use SupressDIPLunch of search time is for dinner
--********************************************
SELECT
			pp.PromoID
			,pr.RID	
			,[BeginDate] = COALESCE(pp.EventStartDate,dateadd(d,-1,getdate())) 
			,[EndDate] = COALESCE(pp.EventEndDate,dateadd(d,60,begindate)) 			
			-- Suppress DIP Lunch if the promo is set for a dip exclusion and the restaurant is participating in Lunch
			-- or if the restaurant has been explicitly set to exclude DIP lunch in the exclusion table
			,[SuppressDIPLunch] = (case 
								when pe.RID IS NOT NULL THEN convert(bit,IsNull(pe.SupressDIPLunch,0))
								when pp.SuppressDIP = 1 and pp.PromoSearchTypeID in (4,11) then convert(bit, pr.Lunch)
								when pp.SuppressDIP = 1 then convert(bit, 1)
								else convert(bit,0)
								end)
			-- Suppress DIP Dinner if the promo is set for a dip exclusion and the restaurant is participating in Dinner
			-- or if the restaurant has been explicitly set to exclude DIP Dinner in the exclusion table
			,[SuppressDIPDinner] = (case 
								when pe.RID IS NOT NULL THEN convert(bit,IsNull(pe.SupressDIPDinner,0))
								when pp.SuppressDIP = 1 and pp.PromoSearchTypeID in (4,11) then convert(bit, pr.Dinner)
								when pp.SuppressDIP = 1 then convert(bit, 1)
								else convert(bit,0)
								end)
FROM		dbo.PromoPages pp
INNER JOIN	PromoRests pr
ON			pp.PromoID = pr.PromoID
LEFT JOIN	PromoDIPSupressExclusion pe
ON			pe.rid = pr.rid
AND			pe.promoid = pp.promoid
WHERE		pp.active = 1
AND			EndDate > GETDATE() - 1
AND			(	-- Only retrieve Promos that have an explicit suppression
				SuppressDIP = 1
				or pe.RID is not null
			)


GO

GRANT EXECUTE ON [ObjectCacheRestPromoDIPSuppression] TO ExecuteOnlyRole

GO
