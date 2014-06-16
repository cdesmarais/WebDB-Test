

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Referrer_Add1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Referrer_Add1]
go

/*
	This stored procedure adds a new Referrer to the Referrer table
*/

create procedure dbo.Admin_Referrer_Add1
(
	@Name nvarchar(255)
	, @SuppressAlternative int
	, @ReportingSourceTypeID int
	, @ReportingDisplayName nvarchar(256)
	, @Notes nvarchar(500)
)
As
SET NOCOUNT ON
begin transaction

insert into Referrer
(
	ReferrerName
	, SuppressAlternative
	, ReportingSourceTypeID
	, ReportingDisplayName
	, Notes
)
values
(
	@Name
	, @SuppressAlternative
	, @ReportingSourceTypeID
	, @ReportingDisplayName
	, @Notes
)
if (@@ERROR <> 0)
	goto general_error

select scope_identity()as ReferrerId

commit transaction
Return(0)

general_error:
	rollback transaction
	Return(0)

go

grant execute on [Admin_Referrer_Add1] to ExecuteOnlyRole

go


