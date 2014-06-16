if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTGetTierInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTGetTierInfo]
GO



CREATE PROCEDURE dbo.OTGetTierInfo
AS
-- get all Open Alerts..
select * from otalerttiers
GO


GRANT EXECUTE ON [OTGetTierInfo] TO ExecuteOnlyRole

GO
