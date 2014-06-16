if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAddABFilterReso]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAddABFilterReso]
GO


CREATE PROCEDURE dbo.DNAddABFilterReso
(
		@ABFilterID int,
		@ResID int,
		@FeatActive bit,	-- FeatActive = 1 when feature was showing when reso was made. This is for times when its possible that you dont see the feature but are in the population that sees it
		@FeatShown bit		-- FeatShown = 1 for population that SEES feature, 0 for population that DOES NOT see it..
)

AS

-- perform insert into ABFilterResos
if not exists(select resid from ABFilterResos where ResID=@ResID AND ABFilterID=@ABFilterID)
BEGIN
	insert into ABFilterResos(ABFilterID,ResID,FeatureActive,InShowGroup) values(@ABFilterID,@ResID,@FeatActive,@FeatShown)
END

GO

GRANT EXECUTE ON [DNAddABFilterReso] TO ExecuteOnlyRole

GO
