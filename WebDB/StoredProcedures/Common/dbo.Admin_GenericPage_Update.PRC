if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GenericPage_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GenericPage_Update]
GO

CREATE PROCEDURE dbo.Admin_GenericPage_Update
(
  @Name nvarchar(50),
  @Content ntext,
  @LastUpdatedBy nvarchar(255),
  @PageID INT,
  @LanguageID INT
)
As
SET NOCOUNT ON

Update GenericPageLocal Set 
	Name=@Name,
	Content=@Content,
	LastUpdatedBy=@LastUpdatedBy,
	UpdatedDate = getdate()
where 	PageID = @PageID 
and 	LanguageID = @LanguageID

GO

GRANT EXECUTE ON [Admin_GenericPage_Update] TO ExecuteOnlyRole

GO
