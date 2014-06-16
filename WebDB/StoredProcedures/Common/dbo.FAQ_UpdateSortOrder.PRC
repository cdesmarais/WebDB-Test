if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FAQ_UpdateSortOrder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FAQ_UpdateSortOrder]
GO

CREATE PROCEDURE dbo.FAQ_UpdateSortOrder
(@FAQID int
,@sort int)
AS

SET NOCOUNT ON

BEGIN TRANSACTION
Update FAQValues
Set SortOrder = @sort
Where FAQID = @FAQID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [FAQ_UpdateSortOrder] TO ExecuteOnlyRole

GO
