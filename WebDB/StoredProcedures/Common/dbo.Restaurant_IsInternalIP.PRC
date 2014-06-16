if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_IsInternalIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_IsInternalIP]
GO


CREATE PROCEDURE dbo.Restaurant_IsInternalIP 
(               
	@IPAddr nvarchar(255)
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
if (exists (select IPID from InternalIP where ip = @IPAddr))
	BEGIN
		RETURN(1)
	END

-- otherwise....
RETURN(0)

GO

GRANT EXECUTE ON [Restaurant_IsInternalIP] TO ExecuteOnlyRole

GO
