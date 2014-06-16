/* Dropping this stored proc since we're at least 2 versions beyond this one */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerAdd3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerAdd3]
GO
