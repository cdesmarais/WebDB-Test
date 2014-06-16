if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetPublisherByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetPublisherByID]
GO




CREATE PROCEDURE dbo.Admin_GetPublisherByID

(@Pub_ID int
 )

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT PubID as Pub_ID,MPName as Name,logo,active
FROM MediaPublishers where PubID = @Pub_ID
GO

GRANT EXECUTE ON [Admin_GetPublisherByID] TO ExecuteOnlyRole

GO
