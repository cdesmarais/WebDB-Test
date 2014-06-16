if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Allotment_GetFaxInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Allotment_GetFaxInfo]
GO

--**************************************
--** OBSOLETE: Allotment no longet supported
--** EV: 10/14/2007
--**************************************

