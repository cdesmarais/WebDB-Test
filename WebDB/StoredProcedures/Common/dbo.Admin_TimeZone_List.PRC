if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_TimeZone_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_TimeZone_List]
GO




/****** Object:  Stored Procedure dbo.Admin_TimeZone_List    Script Date: 2/7/2000 3:55:29 PM ******/
CREATE PROCEDURE dbo.Admin_TimeZone_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		TZID AS TimeZoneID,
			TZName as Name,
			Code,
			_OffsetHR Offset
FROM		TimeZone
GO

GRANT EXECUTE ON [Admin_TimeZone_List] TO ExecuteOnlyRole

GO
