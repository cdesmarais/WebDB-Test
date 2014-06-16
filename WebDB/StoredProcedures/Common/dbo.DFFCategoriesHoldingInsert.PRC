if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFCategoriesHoldingInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFCategoriesHoldingInsert]
GO
/*	
	Procedure to insert a row into DFFCategoriesHolding table
*/
CREATE PROCEDURE dbo.DFFCategoriesHoldingInsert
( 		
		 @CategoryID int
		,@Description nvarchar(400)		
)
AS
SET NOCOUNT ON
		
		
INSERT INTO [dbo].[DFFCategoriesHolding]
            (
			  CategoryID
			 ,Description 			 
			)
     VALUES
           ( 
			 @CategoryID 
			,@Description 			
			)
           
GO


GRANT EXECUTE ON [dbo].[DFFCategoriesHoldingInsert] TO ExecuteOnlyRole

GO

