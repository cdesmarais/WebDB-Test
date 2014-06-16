if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RingRevenueInsertRunLogEntry]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RingRevenueInsertRunLogEntry]
GO

CREATE PROCEDURE [dbo].[RingRevenueInsertRunLogEntry]
(
   @AfterTransactionID VARCHAR(20)
)
AS
	SET NOCOUNT ON
	INSERT INTO dbo.RingRevenueRunLog
	(
		AfterTransactionID
	)
	VALUES 
	(
		@AfterTransactionID
	)
	
	SELECT SCOPE_IDENTITY()
GO

GRANT EXECUTE ON [RingRevenueInsertRunLogEntry] TO ExecuteOnlyRole
GO
