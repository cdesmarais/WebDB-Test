
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePrivateEventFeatureRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePrivateEventFeatureRests]
go

CREATE PROCEDURE [dbo].[DNCachePrivateEventFeatureRests]
AS

SELECT PrivateEventID, pefr.RestaurantID, r.Rname
FROM PrivateEventFeaturedrest pefr
INNER JOIN Restaurantvw r ON r.rid = pefr.RestaurantID
ORDER BY PrivateEventID

go

GRANT EXECUTE ON [DNCachePrivateEventFeatureRests] TO ExecuteOnlyRole
GO
