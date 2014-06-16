
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetResID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetResID]
GO


CREATE PROCEDURE [dbo].[procGetResID]
@ResID INT OUTPUT
AS
BEGIN 

INSERT INTO ReservationID DEFAULT VALUES

SELECT		@ResID = SCOPE_IDENTITY()

END
GO



GRANT EXECUTE ON [procGetResID] TO ExecuteOnlyRole

GO

