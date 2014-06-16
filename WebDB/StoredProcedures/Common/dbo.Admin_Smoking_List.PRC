if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Smoking_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Smoking_List]
GO

CREATE Procedure dbo.Admin_Smoking_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SmokingID AS SmokingID
,Smoking as Value
FROM Smoking
ORDER BY Smoking

GO

GRANT EXECUTE ON [Admin_Smoking_List] TO ExecuteOnlyRole

GO
