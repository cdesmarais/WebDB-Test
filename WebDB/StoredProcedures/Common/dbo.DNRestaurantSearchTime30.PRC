
--*********************************************************
--** Retrieves a list of RID, with Time sensitive data 
--** IsBlockedDay, cutoff_time, realtime, etc...
--** Joined with a "chached" table of static restaurant data
--** Reduces abount of joins done in a traditional search query
--*********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantSearchTime30]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantSearchTime30]
GO

--*********************************************************
--** EV: 01/11/07: Obsolete: Removed in tag: Web_4_4_4
--*********************************************************
