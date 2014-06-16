if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DressCode_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DressCode_List]
GO

CREATE Procedure dbo.Admin_DressCode_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		DressCodeID AS DressCodeID
			,DressCode as Value
FROM		DressCodeVW
ORDER BY	DressCode

GO

GRANT EXECUTE ON [Admin_DressCode_List] TO ExecuteOnlyRole

GO
