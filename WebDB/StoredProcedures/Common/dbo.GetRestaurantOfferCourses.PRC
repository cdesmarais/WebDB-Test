if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantOfferCourses]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantOfferCourses]
GO

--
-- Gets all the restaurant offer courses for the given language
-- 

CREATE Procedure dbo.GetRestaurantOfferCourses
As

SELECT	RestaurantOfferCourseID,
		CourseName
FROM	RestaurantOfferCourseVW

GO

GRANT EXECUTE ON [GetRestaurantOfferCourses] TO ExecuteOnlyRole

GO

