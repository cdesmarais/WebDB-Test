if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSaveDiningFormCategories]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSaveDiningFormCategories]
GO


-- Save category data
CREATE PROCEDURE dbo.DNSaveDiningFormCategories
(
     @theResID int,
     @theCatIDS nvarchar(1000),
     @IsPicked bit
)

AS

-- if resid already exists - exit, because you've already saved some type of preference..
if exists(select resid from DiningFormCategoryResponses where resid=@theResID and Picked=@IsPicked)
BEGIN
	return;
END


INSERT into DiningFormCategoryResponses 
      select @theResID,
            id, -- CategoryID
             @IsPicked
      from fIDStrToTab(@theCatIDS, ',')



GO

GRANT EXECUTE ON [DNSaveDiningFormCategories] TO ExecuteOnlyRole

GO
