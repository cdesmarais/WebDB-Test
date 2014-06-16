if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNListActiveRestaurantIncentivesByMetroID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNListActiveRestaurantIncentivesByMetroID]
GO

--******************************
--**OBSOLETE: Officialy removed from source base as of Web_4_4_4
--******************************

