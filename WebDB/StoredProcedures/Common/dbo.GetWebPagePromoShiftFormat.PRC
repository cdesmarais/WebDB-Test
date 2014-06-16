
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetWebPagePromoUploadShiftFormat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetWebPagePromoUploadShiftFormat]
GO

create procedure dbo.GetWebPagePromoUploadShiftFormat
as  
set NOCOUNT on

-- This Proc is used to get Web Promo Page Upload Shift Format

begin
	select   
		ShiftFormatID
	   	,ShiftFormatDisplayName	   
	from
		WebPagePromoUploadShiftFormatVW
end
GO

grant execute on [GetWebPagePromoUploadShiftFormat] to ExecuteOnlyRole
GO


