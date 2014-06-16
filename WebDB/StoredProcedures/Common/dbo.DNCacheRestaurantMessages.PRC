if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantMessages]
GO



CREATE PROCEDURE [dbo].[DNCacheRestaurantMessages] AS

set transaction ISOLATION LEVEL read UNCOMMITTED

SELECT	a.RID
		,b.Hours AS Hours
		,b.SpecialEvents AS SpecialEvents
		,b.ParkingDescription AS ParkingDescription
		,b.CaterDescription as Cater_Description
		,b.PublicTransit AS PublicTransit
		,b.PrivatePartyDescription AS PrivatePartyDescription
		,b.BanquetDescription AS BanquetDescription
		,b.Entertainment
		,b.SpecialEventsStartDate
		,b.SpecialEventsEndDate
		,b.PrivatePartyLongDecription

FROM		RestaurantMessageVW b
INNER JOIN	RestaurantVW a
on		a.RID=b.rid
and		a.languageid=b.languageid

WHERE	a.RestStateID <> 4
option (ROBUST PLAN)   --Note this needs to remain, without the option the query fails in pre-prod and daybehind
					   --Please see AV or JC if have questions

GO


GRANT EXECUTE ON [dbo].[DNCacheRestaurantMessages] TO ExecuteOnlyRole

GO
