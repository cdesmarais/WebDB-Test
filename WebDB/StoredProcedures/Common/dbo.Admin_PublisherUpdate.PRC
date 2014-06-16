if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PublisherUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PublisherUpdate]
GO




CREATE PROCEDURE dbo.Admin_PublisherUpdate

(@name nvarchar(100),
 @logo nvarchar(300),
 @active bit,
 @Pub_ID int
 )

AS
SET NOCOUNT ON

UPDATE MediaPublishers SET MPName=@name,logo=@logo,active=@active WHERE PubID=@Pub_ID
GO

GRANT EXECUTE ON [Admin_PublisherUpdate] TO ExecuteOnlyRole

GO
