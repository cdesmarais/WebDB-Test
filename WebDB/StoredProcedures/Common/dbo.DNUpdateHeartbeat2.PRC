if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateHeartbeat2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateHeartbeat2]
GO
--Obsolete
--jon added Feb 6, 2007
