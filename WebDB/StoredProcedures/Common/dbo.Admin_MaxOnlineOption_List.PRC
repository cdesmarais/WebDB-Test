if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MaxOnlineOption_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MaxOnlineOption_List]
GO


CREATE Procedure dbo.Admin_MaxOnlineOption_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
MaxOnlineOptionID AS MaxOnlineOptionID
,MaxOnlineOption as Value
FROM MaxOnlineOption

GO

GRANT EXECUTE ON [Admin_MaxOnlineOption_List] TO ExecuteOnlyRole

GO
