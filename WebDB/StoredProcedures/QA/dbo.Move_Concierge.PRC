if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Move_Concierge]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Move_Concierge]
GO


CREATE PROCEDURE dbo.Move_Concierge
(
    @CallerID int
)

AS

update caller set companyID = null where callerID = @CallerID


GO

GRANT EXECUTE ON [Move_Concierge] TO ExecuteOnlyRole

GO
