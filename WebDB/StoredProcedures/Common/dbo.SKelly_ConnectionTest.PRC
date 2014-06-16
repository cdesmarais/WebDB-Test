if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SKelly_ConnectionTest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SKelly_ConnectionTest]
GO



CREATE Procedure dbo.SKelly_ConnectionTest
(@retVal int  OUTPUT
)
AS
SET NOCOUNT ON

set @retVal = 1



GO

GRANT EXECUTE ON [SKelly_ConnectionTest] TO ExecuteOnlyRole

GO
