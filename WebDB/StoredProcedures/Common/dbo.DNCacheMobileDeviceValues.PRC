
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheMobileDeviceValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheMobileDeviceValues]
GO



CREATE PROCEDURE dbo.DNCacheMobileDeviceValues
As
set nocount on
set transaction isolation level read uncommitted

exec dbo.procGetValueLookupsByType 'MOBILEDEVICE'

GO

SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [DNCacheMobileDeviceValues] TO ExecuteOnlyRole

GO
