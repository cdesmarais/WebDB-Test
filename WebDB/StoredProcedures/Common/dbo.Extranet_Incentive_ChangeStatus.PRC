if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_ChangeStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_ChangeStatus]
GO




CREATE Procedure dbo.Extranet_Incentive_ChangeStatus

@IncentiveID int,
@Active bit

AS
SET NOCOUNT ON

update Incentive set active = @Active where incentiveid = @IncentiveID


GO

GRANT EXECUTE ON [Extranet_Incentive_ChangeStatus] TO ExecuteOnlyRole

GO
