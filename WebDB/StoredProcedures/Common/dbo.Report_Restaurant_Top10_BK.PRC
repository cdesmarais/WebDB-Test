if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_Top10_BK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_Top10_BK]
GO

--*********************************
--**  OBSOLETE: As of i18n phase2
--*********************************

