
if  exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[ROMS_Delete_RestToGroup]') and type in (N'P', N'PC'))
drop procedure [dbo].[ROMS_Delete_RestToGroup]
go

create Procedure [dbo].[ROMS_Delete_RestToGroup]  
   
as  

delete   
 from GOD_RestToGroupAssoc  
go

grant execute on [ROMS_Delete_RestToGroup] to ExecuteOnlyRole
go  

