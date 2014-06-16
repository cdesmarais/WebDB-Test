/* Dropping this stored proc since we're at least 2 versions beyond this one */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerUpdate]
GO
