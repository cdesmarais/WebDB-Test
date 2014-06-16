if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ConnectionIssue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ConnectionIssue]
GO

CREATE PROCEDURE dbo.Restaurant_ConnectionIssue
 (               
        @RID int
,	@Reason nvarchar(50) = ''
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 


Select RName 
from restaurantVW 
where RID = @RID
GO

GRANT EXECUTE ON [Restaurant_ConnectionIssue] TO ExecuteOnlyRole

GO
