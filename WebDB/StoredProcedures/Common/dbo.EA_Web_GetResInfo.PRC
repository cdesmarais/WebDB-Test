if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EA_Web_GetResInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[EA_Web_GetResInfo]
GO



CREATE PROCEDURE dbo.EA_Web_GetResInfo
  
As

/* This proc does nothing, but is used by OpenTable3 */

GO

GRANT EXECUTE ON [EA_Web_GetResInfo] TO ExecuteOnlyRole

GO

