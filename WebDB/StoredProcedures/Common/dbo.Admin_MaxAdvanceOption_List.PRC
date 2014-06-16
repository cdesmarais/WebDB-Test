if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MaxAdvanceOption_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MaxAdvanceOption_List]
GO

CREATE Procedure dbo.Admin_MaxAdvanceOption_List
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select MaxAdvanceOptionID
, MaxAdvanceOption as Value 
from MaxAdvanceOption
order by days
GO


GRANT EXECUTE ON [Admin_MaxAdvanceOption_List] TO ExecuteOnlyRole

GO
