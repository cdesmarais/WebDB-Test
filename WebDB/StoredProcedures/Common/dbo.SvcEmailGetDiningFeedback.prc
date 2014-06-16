if exists (select * from dbo.sysobjects where ID = object_id(N'[dbo].[SvcEmailGetDiningFeedback]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[SvcEmailGetDiningFeedback]
GO

--******************************
--** Obsolete this proc is now obsolete
--** Replaced by: SvcEmailGetDiningFeedback2
--******************************