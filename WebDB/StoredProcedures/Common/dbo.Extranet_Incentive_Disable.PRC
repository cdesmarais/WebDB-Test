if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_Disable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_Disable]
GO




CREATE Procedure dbo.Extranet_Incentive_Disable

@IncentiveID int

AS
SET NOCOUNT ON

update Incentive set active = 0,datedisabled = getdate() where incentiveid = @IncentiveID


GO

GRANT EXECUTE ON [Extranet_Incentive_Disable] TO ExecuteOnlyRole

GO
