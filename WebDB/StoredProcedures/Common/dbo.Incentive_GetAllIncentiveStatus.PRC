if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetAllIncentiveStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetAllIncentiveStatus]
GO

CREATE procedure [dbo].[Incentive_GetAllIncentiveStatus]

as

SELECT IncStatusID, Status from IncentiveStatus

Go

GRANT EXECUTE ON [Incentive_GetAllIncentiveStatus] TO ExecuteOnlyRole



GO
