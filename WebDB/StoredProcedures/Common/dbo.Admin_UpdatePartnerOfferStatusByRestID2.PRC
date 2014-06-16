/* Once run for Web_12_7 deployment delete from SVN */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdatePartnerOfferStatusByRestID2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdatePartnerOfferStatusByRestID2]
GO
