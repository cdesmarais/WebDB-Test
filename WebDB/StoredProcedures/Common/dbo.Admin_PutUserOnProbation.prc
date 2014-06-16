-- OBSOLETE.  Removed in Web_10_2
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PutUserOnProbation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PutUserOnProbation]
go
