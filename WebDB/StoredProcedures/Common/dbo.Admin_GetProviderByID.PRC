if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetProviderByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetProviderByID]
GO




CREATE PROCEDURE dbo.Admin_GetProviderByID

(@Restaurant_ID int
 )

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select Count(ProviderID) As tot from Content where ProviderID=1 AND RID=@Restaurant_ID
GO

GRANT EXECUTE ON [Admin_GetProviderByID] TO ExecuteOnlyRole

GO
