if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNQAListAllRestaurantIncentives]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNQAListAllRestaurantIncentives]
GO

--******************************
--**OBSOLETE: Officialy removed from source base as of Web_4_4_4
--******************************

