if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTGetAlertTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTGetAlertTypes]
GO



CREATE PROCEDURE dbo.OTGetAlertTypes
AS
-- get all Alerts types
select * from otalerttype
GO

GRANT EXECUTE ON [OTGetAlertTypes] TO ExecuteOnlyRole

GO
