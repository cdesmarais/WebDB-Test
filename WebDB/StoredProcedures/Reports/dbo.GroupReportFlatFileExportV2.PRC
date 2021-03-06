if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GroupReportFlatFileExportV2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GroupReportFlatFileExportV2]
GO


create  Procedure [dbo].[GroupReportFlatFileExportV2]
(
  @GID int,
  @DateOffset int
)
AS
--*****************************************
--** GroupReportFlatFileExportV2 is new was fromerly GroupReportFlatFileExport
--** This proc is called by M&SReports DTS package
--** Columns exponsing Firsttime values have been removed
--** TODO: Consider removing all references to Reservation.FirstTime 
--*****************************************

set transaction isolation level read uncommitted

select	NULL RefUnit,
		R.RID,
		R.RName, 
		R.City,
		left(cast(cast(getdate()as int)+(@DateOffset-8) as datetime),12) [Week Of],
		coalesce(Made.OT_Covers, 0) [OT Covers Made],
		coalesce(Made.MS_Covers, 0) [M&S Covers Made],
		coalesce(Made.OT_Covers_pending, 0) [OT Covers Pending],
		coalesce(Made.MS_Covers_pending, 0) [M&S Covers Pending],
		coalesce(Made.OT_Covers_seated, 0) [OT Covers Seated],
		coalesce(Made.MS_Covers_seated, 0) [M&S Covers Seated],
		coalesce(Made.OT_Covers_NoShow, 0) [OT Covers NoShow],
		coalesce(Made.MS_Covers_NoShow, 0) [M&S Covers NoShow],
		coalesce(Made.OT_Covers_Cancel, 0) [OT Covers Cancel],
		coalesce(Made.MS_Covers_Cancel, 0) [M&S Covers Cancel],
		coalesce(Seated.OT_Covers_Seated, 0) [Total OT Seated Covers],
		coalesce(Seated.MS_Covers_Seated, 0) [Total M&S Seated Covers]
		from	restaurantVW R
		inner join 
		RestaurantToGroup RTG
		on		R.RID = RTG.RID
		Left join 
		(select	
				R.RID, 
				sum(
					case when OTRes.billingType = 'OTReso'
					then OTRes.BillableSize
					else 0	end) 
					as OT_Covers_Seated, 
				sum(case when OTRes.billingType = 'RestRefReso'
					then	OTRes.BillableSize
					else	0 end)		
					as MS_Covers_Seated
		from	restaurant R
		inner join 
				RestaurantToGroup RTG
		on		R.RID = RTG.RID
		inner join 
				reservationVW OTRes
		on		OTRes.RID = R.RID
		where	shiftdate between cast(cast(getdate()as int)+(@DateOffset-8) as datetime) and 
		cast(cast(getdate()as int)+(@DateOffset-1) as datetime)
		and		RTG.GID>0 
		and		GID =@GID
		and		OTRes.RstateID in(1,2,5,6,7)
		group by R.RID) SEATED
		on Seated.RID = R.RID 
		Left Join	
		(select	
				R.RID, 
				sum(case when OTRes.billingType = 'OTReso'
					then OTRes.BillableSize
					else 0	end) 
					as OT_Covers, 
				sum(case when OTRes.billingType = 'RestRefReso'
					then	OTRes.BillableSize
					else 0 end)		
					as MS_Covers,
				sum(case when OTRes.billingType = 'OTReso' and OTRes.RstateID = 1 
					then OTRes.BillableSize
					else 0	end)
					as OT_Covers_Pending, 
				sum(case when OTRes.billingType = 'RestRefReso' and OTRes.RstateID = 1 
					then OTRes.BillableSize
					else 0	end)
					as MS_Covers_Pending, 
				sum(case when OTRes.billingType = 'OTReso' and OTRes.RstateID in (2,5,6,7) 
					then OTRes.BillableSize
					else 0	end) 
					as OT_Covers_Seated, 
				sum(case when OTRes.billingType = 'RestRefReso' and OTRes.RstateID in (2,5,6,7) 
					then OTRes.BillableSize
					else 0	end) 
					as MS_Covers_Seated, 
				sum(case when OTRes.billingType='OTReso' and OTRes.RstateID in (4,10) 
					then OTRes.BillableSize
					else 0	end)
					as OT_Covers_NoShow, 
				sum(case when OTRes.billingType = 'RestRefReso' and OTRes.RstateID in (4,10) 
					then OTRes.BillableSize
					else 0	end)
					as MS_Covers_NoShow, 
				sum(case when OTRes.billingType='OTReso' and OTRes.RstateID in (3,8,10) 
					then OTRes.BillableSize
					else 0	end)
					as OT_Covers_Cancel, 
				sum(case when OTRes.billingType = 'RestRefReso' and OTRes.RstateID in (3,8,10) 
					then OTRes.BillableSize
					else 0	end)
					as MS_Covers_Cancel,
				sum(case when FirstTime = 1 then 1 else 0 end) 
					as FirstTime_Resos, 	
				sum(case when FirstTime = 1 then OTRes.BillableSize else 0 end) 
					as FirstTime_Covers, 	
				sum(case when OTRes.BillingType = 'RestRefReso' and FirstTime = 1 then 1 else 0 end) 
					as MS_FirstTime_Resos, 	
				sum(case when OTRes.BillingType = 'RestRefReso' and FirstTime = 1 then OTRes.BillableSize else 0 end) 
					as MS_FirstTime_Covers, 
				sum(case when OTRes.BillingType = 'OTReso' and FirstTime = 1 then 1 else 0 end) 
					as OT_FirstTime_Resos,
				sum(case when OTRes.BillingType = 'OTReso' and FirstTime = 1 then OTRes.BillableSize else 0 end) 
					as OT_FirstTime_Covers 
			from	restaurant R
			inner join 
					RestaurantToGroup RTG
			on		R.RID = RTG.RID
			inner join 
					reservationVW OTRes
			on		OTRes.RID = R.RID
			where	datemade between cast(cast(getdate()as int)+(@DateOffset-8) as datetime) and 
			cast(cast(getdate()as int)+(@DateOffset-1) as datetime)
			and		RTG.GID>0 
			and		GID =@GID
			group by R.RID
		) MADE
		on MADE.RID = R.RID 
		where	RTG.GID>0 
		and		GID =@GID
		and 	Made.OT_Covers > 0
		and		Made.MS_Covers > 0
		order by R.City, Made.OT_Covers
GO



GRANT EXECUTE ON [GroupReportFlatFileExportV2] TO ExecuteOnlyRole

GO

