if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FAQ_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FAQ_GetByID]
GO

CREATE PROCEDURE dbo.FAQ_GetByID
(
  @FAQID int
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select 
	  FAQID
	 ,FAQTypeID
	 ,FAQquestion
	 ,FAQanswer
	 ,active
	 ,FAQshortdesc
From  FAQValues
Where FAQID = @FAQID

GO

GRANT EXECUTE ON [FAQ_GetByID] TO ExecuteOnlyRole

GO
