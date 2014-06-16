if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListSynchronizeRegionListEUAsia]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListSynchronizeRegionListEUAsia]
GO



CREATE PROCEDURE [dbo].[TopTenListSynchronizeRegionListEUAsia] as
/* 
This proc synchronizes regional lists for EU and Asia.  Currently
DFF is not active in EU and Asia, so we do not consider this value
when determining if a region is valid
*/

SET NOCOUNT ON
declare @UseDFFStartDT bit
set @UseDFFStartDT = 0

exec procTopTenListSynchronizeRegionList @UseDFFStartDT

go

grant execute on [TopTenListSynchronizeRegionListEUAsia] to executeonlyrole

go


