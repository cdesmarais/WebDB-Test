if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListPaymentTypesByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListPaymentTypesByID]
GO

--**************************************************************************************
--** Proc marked for deletion TT: 22393
--**
--** OBSOLETE WR10_4
--**************************************************************************************
