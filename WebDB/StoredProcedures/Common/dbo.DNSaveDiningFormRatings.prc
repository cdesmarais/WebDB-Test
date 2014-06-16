if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSaveDiningFormRatings]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSaveDiningFormRatings]
GO


-- Save category data
CREATE PROCEDURE dbo.DNSaveDiningFormRatings
(
     @theResID int,
     @theRatingSectionItemID int,
     @theRatTypeDetailIDS nvarchar(1000),
     @IsPicked bit
)

AS

-- if ratings for this rating section and resid exist - go away..
if exists (select resid from DiningFormRatingsResponses where resid=@theResID and RatingSectionItemID=@theRatingSectionItemID and Picked=@IsPicked)
BEGIN
	return;
END


INSERT into DiningFormRatingsResponses (ResId, RatingSectionItemID, RatingsTypeDetailID, Picked)
      select	@theResID,
				@theRatingSectionItemID,
				id, -- RatingsTypeDetailID
				@IsPicked
      from fIDStrToTab(@theRatTypeDetailIDS, ',')

GO

GRANT EXECUTE ON [DNSaveDiningFormRatings] TO ExecuteOnlyRole

GO
