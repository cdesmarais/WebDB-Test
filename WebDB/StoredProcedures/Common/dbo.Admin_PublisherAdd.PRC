if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PublisherAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PublisherAdd]
GO




CREATE PROCEDURE dbo.Admin_PublisherAdd

(@name nvarchar(100),
 @logo nvarchar(300),
 @active bit
 )

AS
SET NOCOUNT ON

INSERT INTO MediaPublishers(MPName,logo,active) 
values (@name,@logo,@active)




GO

GRANT EXECUTE ON [Admin_PublisherAdd] TO ExecuteOnlyRole

GO
