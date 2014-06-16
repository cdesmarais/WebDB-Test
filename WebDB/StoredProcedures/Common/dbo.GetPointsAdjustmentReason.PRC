


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPointsAdjustmentReason]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetPointsAdjustmentReason]
GO

create procedure dbo.GetPointsAdjustmentReason
as

/***********************************************************************
Purpose: Get Point Adjustment Reason information to display on charm UI.
************************************************************************/

SET NOCOUNT ON    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

select 
	AdjReasonID,
	CHARMExplanation
from
	PointsAdjustmentReason
where
	ShowInUI = 1
order by
	UIViewOrder
	
GO

GRANT EXECUTE ON [GetPointsAdjustmentReason] TO ExecuteOnlyRole
GO