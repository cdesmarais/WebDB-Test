
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_ResponseTimeByMinute]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_ResponseTimeByMinute]
GO

--OBSOLETE: EV: 8/16/08  Delete ME

