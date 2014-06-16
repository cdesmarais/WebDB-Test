if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferStatuses]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferStatuses]
GO

--
-- Gets all the restaurant offer status values 
-- 

CREATE Procedure dbo.GetRestaurantOfferStatuses

As

SELECT	
		RestaurantOfferStatusID
		,StatusName
FROM	
		RestaurantOfferStatusVW
ORDER BY Rank Asc

GO

GRANT EXECUTE ON [GetRestaurantOfferStatuses] TO ExecuteOnlyRole

GO

