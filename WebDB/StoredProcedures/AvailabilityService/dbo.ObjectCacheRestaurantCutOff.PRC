if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheRestaurantCutOff]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheRestaurantCutOff]
GO

CREATE PROCEDURE dbo.ObjectCacheRestaurantCutOff
 As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @wk_yesterday datetime
declare @wk_tomorrow datetime
declare @weekday datetime
declare @res_date datetime

SELECT
    @weekday			= datepart(dw,getdate())
    ,@wk_tomorrow		= datepart(dw,getdate()+1)
    ,@wk_yesterday		= datepart(dw,getdate()-1)
    ,@res_date			= cast(convert(nvarchar, getdate(), 110) as datetime)

-- Retrieve Cut off times for today, yesterday, and tomorrow
SELECT 
			st.RID
			, searchDt = (case 
				when scheduleid = @wk_yesterday then DATEADD(d, -1, @res_date)
				when scheduleid = @weekday		then DATEADD(d, 0, @res_date)
				when scheduleid = @wk_tomorrow	then DATEADD(d, 1, @res_date)
			end)
			,st.ResCutOffTime as cutoff_time
			,s.ShiftName 'SName'
			,st.opentime 
			,st.closetime 

FROM		shifttemplate st
INNER JOIN	scheduleshifts ss
ON			st.shifttemplateid = ss.shifttemplateid
AND			st.RID = ss.RID
INNER JOIN	shift s
ON			ss.shiftid = s.shiftid
WHERE		ss.scheduleid in (@wk_yesterday, @weekday, @wk_tomorrow) -- look behind a day and ahead a day
AND			st.shiftid = ss.shiftid
AND			st.active = 1
AND			st.cutoffactive = 1		
AND			st.ResCutoffTime is NOT NULL 
AND			st.opentime is NOT NULL 
AND			st.closetime is NOT NULL  

GO

GRANT EXECUTE ON [ObjectCacheRestaurantCutOff] TO ExecuteOnlyRole

GO
