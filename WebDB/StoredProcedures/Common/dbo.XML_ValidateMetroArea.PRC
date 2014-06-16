if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_ValidateMetroArea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_ValidateMetroArea]
GO


CREATE PROCEDURE dbo.XML_ValidateMetroArea
(
@MetroArea int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @count int

select @count = count(metroareaid) from MetroArea where metroareaid = @MetroArea
if @count <> 1
	    RAISERROR ('108',16,1) 

GO

GRANT EXECUTE ON [XML_ValidateMetroArea] TO ExecuteOnlyRole

GO
