if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetErrorList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetErrorList]
GO


--******************************
--** TODO: EV: Proc is obsolete and can be retired after i18n Phase2 deployment.
--******************************

CREATE PROCEDURE dbo.DNGetErrorList

AS

SET NOCOUNT ON


SELECT
	ErrorCode, ErrorMessage
	
FROM ErrorMessage
where errorcode is not null

GO


GRANT EXECUTE ON [DNGetErrorList] TO ExecuteOnlyRole

GO
