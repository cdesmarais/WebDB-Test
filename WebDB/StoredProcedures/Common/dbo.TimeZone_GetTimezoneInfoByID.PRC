--
-- New procedure for retriving TZ info
-- MMC 12/30/07 bug 15051
--

-- Use WebDB_MK  

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TimeZone_GetTimezoneInfoByID') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].TimeZone_GetTimezoneInfoByID
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Michael Compton
-- Create date: 12/26/07
-- Description:	retrieve TimeZone info for the given TZID
-- =============================================
CREATE PROCEDURE dbo.TimeZone_GetTimezoneInfoByID
	-- Add the parameters for the stored procedure here
	@TzID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	
			 tz.TZID
			,tz.Code
			,tz.TZName
			,tz.Active
			,tz._offsetMI as GMTTZOffsetMin
			,tz.DSTActive
			,tz.SupportsDST
			,tz.DSTType
			,tz.LastUpdateUTC
			,tz._offsetMI
			,tz._offsetHR
			,tz.ServerOffsetMi
			,tz.ServerGMTOffsetMi
			,tz.ServerToLocalOffsetMi
			,tz.LocalToServerOffsetMi
			,tz.currentLocalTime
			,tz.currentServerTime
	FROM	TimeZoneVW tz
	WHERE	tz.TZID = @TzID


END
GO


GRANT EXECUTE ON [TimeZone_GetTimezoneInfoByID] TO ExecuteOnlyRole

GO
