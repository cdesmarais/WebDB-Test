if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_ListPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_ListPoints]
GO




CREATE Procedure dbo.Extranet_ListPoints

AS 
SET NOCOUNT ON

Select Points,Cost from ExtranetCostPerCover where Active = 1


GO

GRANT EXECUTE ON [Extranet_ListPoints] TO ExecuteOnlyRole

GO
