if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_CancelPendingResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_User_CancelPendingResos]
go
