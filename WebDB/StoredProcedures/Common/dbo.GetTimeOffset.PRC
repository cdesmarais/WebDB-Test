if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetTimeOffset]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetTimeOffset]
GO
--********************************
--** OBSOLETE: Proc no longer called
--** EV: 10/14/2007
--********************************
