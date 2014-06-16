if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Job_ExportCrash_UpgraderInfo_ERB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Job_ExportCrash_UpgraderInfo_ERB]
GO

CREATE PROCEDURE [dbo].[Job_ExportCrash_UpgraderInfo_ERB]
As

-- This proc is called by "Export Upgrader Info" DTS package

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		 r.RID
			,r.RName							'Name'
			,rs.RState							'State'
			,ma.MetroAreaName					'Metro'
			,ltc.LTC							'Last Contact'
			,er.ErbVersion						'ERB Ver'
			,er.ListenerVersion					'OTL Ver'
			,coalesce(er.NetworkAddress,'')		'Current MAC'
			,coalesce(er.NewNetworkAddress,'')	'Next MAC'
			,r.Email							'Email - Website'
			,getdate()							'ReportRunDate'
from		RestaurantVW r
inner join	ErbRestaurant er
on			er.RID			= r.RID
inner join	RestaurantState rs
on			rs.RestStateID	= r.RestStateID
and			rs.RestStateID	!= 4 -- Inactive
inner join	LastTimeContacted ltc
on			ltc.RID			= r.RID
inner join	Neighborhood n
on			n.NeighborhoodID = r.NeighborhoodID
inner join	MetroAreaAVW ma
on			ma.MetroAreaID	= n.MetroAreaID
and			ma.LanguageID	= r.LanguageID
and			ma.MetroAreaID	!= 1 -- not demoland
and			ma.Active		= 1

GO


GRANT  EXECUTE  ON [dbo].[Job_ExportCrash_UpgraderInfo_ERB] TO [ExecuteOnlyRole]
GO
