if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FAQ_GetForSortOrder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FAQ_GetForSortOrder]
GO


CREATE PROCEDURE dbo.FAQ_GetForSortOrder
(
  @typeID nvarchar(3)='0',
  @status nvarchar(1) = ''
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted
if @typeID = '0' SELECT @typeID = ''
if @status is null
	BEGIN
	set @status = ''
	END
 
Select 
FAQValues.FAQID
,FAQValues.FAQType_ID
,FAQValues.FAQquestion
,FAQValues.FAQanswer
,FAQValues.active
,FAQType.FAQTypeDesc
,FAQValues.sortorder
,FAQValues.FAQshortdesc
From FAQValues 
INNER JOIN FAQType 
ON FAQValues.FAQTypeID = FAQType.FAQTypeID
Where  (LEN(@typeID) = 0 
OR CHARINDEX(',' + CAST(FAQValues.FAQTypeID AS nvarchar(3)) + ',', ',' + @typeID + ',') > 0) AND (LEN(@status) = 0 
OR CHARINDEX(',' + CAST(active AS nvarchar(1)) + ',', ',' + @status + ',') > 0)
Order By FAQValues.FAQTypeID
, FAQValues.sortorder ASC

GO

GRANT EXECUTE ON [FAQ_GetForSortOrder] TO ExecuteOnlyRole

GO
