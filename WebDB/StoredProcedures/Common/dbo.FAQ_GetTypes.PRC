if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FAQ_GetTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FAQ_GetTypes]
GO

CREATE PROCEDURE dbo.FAQ_GetTypes
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select 
		 FAQTypeID
		,FAQTypeDesc
From	 FAQType
Order By FAQTypeDesc Asc


GO

GRANT EXECUTE ON [FAQ_GetTypes] TO ExecuteOnlyRole

GO
