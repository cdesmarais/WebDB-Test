if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheLegalContent]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheLegalContent]
GO


CREATE PROCEDURE dbo.DNCacheLegalContent
As
SET NOCOUNT ON
set transaction isolation level read uncommitted  

SELECT LegalPageBody, LegalPageID, DomainID FROM LegalContentVW


GO


GRANT EXECUTE ON [DNCacheLegalContent] TO ExecuteOnlyRole

GO
