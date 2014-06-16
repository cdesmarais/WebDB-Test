if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateDFormEmailSentList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateDFormEmailSentList]
GO
--********************************
--** OBSOLETE: EV 11/12/07: Obsolete. replaced with svcProc
--********************************
