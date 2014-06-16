if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckTopTenforDCWinnerListReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CheckTopTenforDCWinnerListReport]
GO

CREATE PROCEDURE [dbo].[CheckTopTenforDCWinnerListReport]
(
	@TopTenImportJobID int output 
)

AS

Declare @LastSuccesfulTopTenImportJobID int

Set @LastSuccesfulTopTenImportJobID  = 0

Select @LastSuccesfulTopTenImportJobID = ttj.TopTenImportJobID
from TopTenImportJob ttj
LEFT JOIN DCWinnerReportLog dw
ON ttj.TopTenImportJobID = dw.TopTenImportJobID
Where dw.TopTenImportJobID IS NULL
AND coalesce(ttj.Status,1) = 1 

Select @TopTenImportJobID = @LastSuccesfulTopTenImportJobID


Go

GRANT  EXECUTE  ON [CheckTopTenforDCWinnerListReport]  TO [ExecuteOnlyRole]


Go

