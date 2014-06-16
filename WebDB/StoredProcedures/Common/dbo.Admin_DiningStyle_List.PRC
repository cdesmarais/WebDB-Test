if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DiningStyle_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DiningStyle_List]
GO

CREATE Procedure dbo.Admin_DiningStyle_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT   DiningStyleID AS DiningStyleID
        ,DiningStyle as Value
FROM     DiningStyleVW
ORDER BY DiningStyle

GO

GRANT EXECUTE ON [Admin_DiningStyle_List] TO ExecuteOnlyRole

GO
