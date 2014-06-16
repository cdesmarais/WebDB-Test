if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Job_HolidayBlockedDay_USOnly]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Job_HolidayBlockedDay_USOnly]
GO


--************************************
--** This procedure is obsolete as was remove WR82009
--************************************
