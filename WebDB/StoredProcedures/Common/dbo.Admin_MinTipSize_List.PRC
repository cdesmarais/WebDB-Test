if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MinTipSize_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MinTipSize_List]
GO

CREATE Procedure dbo.Admin_MinTipSize_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT MinTipSizeOptionID AS MinTipSizeOptionID,MinTipSizeOption as Value
FROM MinTipSizeOption

GO

GRANT EXECUTE ON [Admin_MinTipSize_List] TO ExecuteOnlyRole

GO
