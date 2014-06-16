if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Walkin_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Walkin_List]
GO

CREATE Procedure dbo.Admin_Walkin_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	WOID AS WalkinOptionID,
		WalkinOption as Value
FROM	WalkinOptionVW
ORDER BY WalkinOption

GO

GRANT EXECUTE ON [Admin_Walkin_List] TO ExecuteOnlyRole

GO
