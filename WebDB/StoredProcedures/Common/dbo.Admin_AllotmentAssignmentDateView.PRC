if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AllotmentAssignmentDateView]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AllotmentAssignmentDateView]
GO


--**************************************
--** OBSOLETE: Allotment no longer supported
--** EV: 10/14/2007
--**************************************


GO
