if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogSearch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogSearch]
GO

CREATE PROCEDURE dbo.DNLogSearch
   (
      @VisitorID nvarchar(24),
      @SessionID nvarchar(24),
      @UserID int,
      @SearchType int,
      @Metro int,
      @MacroNeighborhood int,
      @Neighborhood int,
      @Cuisines nvarchar(50),
      @Prices nvarchar(50),
      @UserType int
   )
As

SET NOCOUNT ON


INSERT INTO WebSiteSearchLog
	(VisitorID,SessionID,UserID,SearchType,Metro,MacroNeighborhood,Neighborhood,Cuisines,Prices,UserType)
	VALUES
	(@VisitorID,@SessionID,@UserID,@SearchType,@Metro,@MacroNeighborhood,@Neighborhood,@Cuisines,@Prices,@UserType)
GO

GRANT EXECUTE ON [DNLogSearch] TO ExecuteOnlyRole

GO
