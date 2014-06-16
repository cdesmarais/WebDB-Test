if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Leading_GetQuarter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Leading_GetQuarter]
GO

CREATE PROCEDURE dbo.Leading_GetQuarter
(
	@MonthNum int
)
AS
SET NOCOUNT ON

Select quarter
From QuarterRef
Where MonthNum = @MonthNum


GO

GRANT EXECUTE ON [Leading_GetQuarter] TO ExecuteOnlyRole

GO
