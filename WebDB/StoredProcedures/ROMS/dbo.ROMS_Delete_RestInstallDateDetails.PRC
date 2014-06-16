
if  exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[ROMS_Delete_RestInstallDateDetails]') and type in (N'P', N'PC'))
drop procedure [dbo].[ROMS_Delete_RestInstallDateDetails]
go

create Procedure [dbo].[ROMS_Delete_RestInstallDateDetails]  
   
as  

delete   
 from GOD_RestInstallDateDetails
   
go

grant execute on [ROMS_Delete_RestInstallDateDetails] to ExecuteOnlyRole
go  

