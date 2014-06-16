if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePrivateEventType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePrivateEventType]
go

CREATE PROCEDURE [dbo].[DNCachePrivateEventType]
AS

SELECT PrivateEventTypeID, Name, FilterKeywords
FROM PrivateEventType

go

GRANT EXECUTE ON [DNCachePrivateEventType] TO ExecuteOnlyRole
GO


