if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNListIncentedRestaurantsByDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNListIncentedRestaurantsByDay]
GO

--******************************
--**OBSOLETE: Officialy removed from source base as of Web_4_4_4
--******************************

