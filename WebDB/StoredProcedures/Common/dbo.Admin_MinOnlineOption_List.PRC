if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MinOnlineOption_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MinOnlineOption_List]
GO

CREATE Procedure dbo.Admin_MinOnlineOption_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT MinOnlineOptionID AS MinOnlineOptionID,MinOnlineOption as Value
FROM MinOnlineOption
GO

GRANT EXECUTE ON [Admin_MinOnlineOption_List] TO ExecuteOnlyRole

GO
