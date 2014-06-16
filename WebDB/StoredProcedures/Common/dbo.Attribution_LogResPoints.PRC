if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Attribution_LogResPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Attribution_LogResPoints]
GO

CREATE PROCEDURE [dbo].[Attribution_LogResPoints]

@ResID					INT,
@PointsNewAttribution	INT,
@PointsOldAttribution	INT,
@PointsRuleID			INT

AS


INSERT INTO			dbo.ResPointsRuleLog
					(
						ResID,
						PointsNewAttribution,
						PointsOldAttribution,
						PointsRuleID
					)
VALUES				(
						@ResID,
						@PointsNewAttribution,
						@PointsOldAttribution,
						@PointsRuleID
					)

GO

GRANT EXECUTE ON [Attribution_LogResPoints] TO ExecuteOnlyRole

GO
