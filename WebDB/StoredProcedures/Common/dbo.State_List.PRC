if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[State_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[State_List]
GO




CREATE Procedure dbo.State_List
As
SET NOCOUNT ON
SELECT StateID AS Abbreviation,
    StateName AS StateName,
    CountryID
FROM StateName
ORDER BY StateName
GO

GRANT EXECUTE ON [State_List] TO ExecuteOnlyRole

GO
