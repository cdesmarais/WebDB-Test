

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Get_Reporting_Source_Type]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_Get_Reporting_Source_Type]
go

/*
	This Stored procedure returns report types that is used by content\referrer_edit.asp, content\PartnerEdit.aspx, content\PartnerAdd.aspx
*/

create procedure dbo.Admin_Get_Reporting_Source_Type
as
SET NOCOUNT ON
	select 
		ReportingSourceTypeID 
		, ReportingSource
	from 
		ReportingSourceType
go

grant execute on [Admin_Get_Reporting_Source_Type] to ExecuteOnlyRole

go


