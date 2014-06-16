if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Weekly_GiftUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Weekly_GiftUpdate]
GO

CREATE PROCEDURE dbo.Report_Weekly_GiftUpdate

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

Update GiftRedemption set Extracted = 1

GO



GRANT EXECUTE ON [Report_Weekly_GiftUpdate] TO ExecuteOnlyRole

GO
