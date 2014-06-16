/* Once run for Web_12_7 deployment delete from SVN */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Add_Simple_v5]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Add_Simple_v5]
GO
