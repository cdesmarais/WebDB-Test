if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListSynchronizeRegionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListSynchronizeRegionList]
GO



CREATE PROCEDURE [dbo].[TopTenListSynchronizeRegionList] as
/* 
This proc synchronizes regional lists that are setup as sub-metro
lists.  These lists will always have a metro counterpart and their list
display order should be the same as that counterpart. This job syncrhonizes
the .com site which has DFF turned on so will be considered.
*/

SET NOCOUNT ON
DECLARE @UseDFFStartDT bit
set @UseDFFStartDT = 1

exec procTopTenListSynchronizeRegionList @UseDFFStartDT

go

grant execute on [TopTenListSynchronizeRegionList] to executeonlyrole

go


