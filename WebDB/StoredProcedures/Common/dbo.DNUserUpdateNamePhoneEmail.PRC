if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserUpdateNamePhoneEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserUpdateNamePhoneEmail]
GO


--**********************************************************
--** OBSOLETE: Depricated as part of the Mobile Phone Support; Proc was never used
--** NC 12/12/07
--**********************************************************


