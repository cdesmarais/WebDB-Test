if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePhoneFormat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePhoneFormat]
GO

CREATE Procedure dbo.DNCachePhoneFormat
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

	select CountryID, PhoneFormatID, PhoneMatchCode
	from PhoneFormat

go

GRANT EXECUTE ON [DNCachePhoneFormat] TO ExecuteOnlyRole

GO
