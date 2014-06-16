if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFCategoriesHoldingDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFCategoriesHoldingDelete]
GO
/*	
	Procedure to delete all rows from DFFCategoriesHolding table
*/
CREATE PROCEDURE dbo.DFFCategoriesHoldingDelete 
AS
SET NOCOUNT ON
				
delete from [dbo].[DffCategoriesHolding]
           
GO

GRANT EXECUTE ON [dbo].[DFFCategoriesHoldingDelete] TO ExecuteOnlyRole

GO

