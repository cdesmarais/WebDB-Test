if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetIncentivesforEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetIncentivesforEmail]
GO

--********************************
--** OBSOLETE: EV 11/12/07: Obsolete. replaced with svcProc
--********************************
