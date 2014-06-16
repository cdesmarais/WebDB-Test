
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].GetWebPagePromoUploadMappingOptions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].GetWebPagePromoUploadMappingOptions
GO

create procedure dbo.GetWebPagePromoUploadMappingOptions
(
	@SupportedShiftFormat varchar(20)
)
as  
set NOCOUNT on

-- This Proc is used to get Web Page Promo Upload Mapping Options

begin
	select   
		 MappingColID
		,DisplayName
		,MappingColDataType
		,MandatoryForMatching
		,SupportedShiftFormat
		,UsedForMatching
		,UploadSPParamName
	from
		WebPagePromoUploadMappingOptionsVW 
	where
		SupportedShiftFormat in (@SupportedShiftFormat,'All') 		
end
GO

grant execute on [GetWebPagePromoUploadMappingOptions] to ExecuteOnlyRole
GO


