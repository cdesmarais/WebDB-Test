
if exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[ROMS_Delete_RestCoversGuaranteeDetails]') and type in (N'P', N'PC'))
drop procedure [dbo].[ROMS_Delete_RestCoversGuaranteeDetails]
go

create Procedure [dbo].[ROMS_Delete_RestCoversGuaranteeDetails] 
   
as 

delete 
 from GOD_RestCoversGuaranteeDetails
   
go

grant execute on [ROMS_Delete_RestCoversGuaranteeDetails] to ExecuteOnlyRole

go 
