


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetAllLegalPagesForDomainID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetAllLegalPagesForDomainID]
go

create procedure [dbo].[Admin_GetAllLegalPagesForDomainID]
(
	 @LegalPageID int
	,@DomainID int
)
as
set transaction isolation level read uncommitted 

/*
	This Stored procedure get legal document of all the language supported by Domain for perticular LegalPageID
	
	Content owned by India team,
    please notify asaxena@opentable.com if changing.
*/

	select 
		 lpl.[LegalPageLocalID]
		,lpl.[LegalPageID]
		,lpl.[LegalPageBody]
		,lpl.[LanguageID]
		,lpl.[DomainID]
		,case when dom.PrimaryLanguageID = lan.LanguageID 
		 then
			1
		 else
			0
		end as IsPrimaryLanguageOfDomain --Checking whether Language is Primary Langauage of Domain.
	from 
		[LegalPagesLocal] lpl
		
		inner join [Language] lan on
		lan.LanguageID = lpl.LanguageID 
		
		inner join [Domain] dom on
		dom.DomainID = lpl.DomainID 
		
	where
		lpl.DomainID = @DomainID
		and lpl.LegalPageID = @LegalPageID
		and lan.Active = 1
		and dom.Active = 1	
	order by
		IsPrimaryLanguageOfDomain desc

go

grant execute on [Admin_GetAllLegalPagesForDomainID] to ExecuteOnlyRole

go



