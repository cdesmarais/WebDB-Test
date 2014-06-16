if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetDiningFeedbackCategories]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[GetDiningFeedbackCategories]
GO

CREATE PROCEDURE dbo.GetDiningFeedbackCategories
 As

SET NOCOUNT ON

	select		cat.CategoryID,
				cat.Description as CategoryName		
	from		DFFCategoriesHoldingVW cat
	order by 	cat.CategoryID
GO

GRANT EXECUTE ON [GetDiningFeedbackCategories] TO ExecuteOnlyRole

GO
