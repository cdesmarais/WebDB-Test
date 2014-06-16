



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateLegalPageForID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateLegalPageForID]
go


create procedure [dbo].[Admin_UpdateLegalPageForID]
(
	 @LegalPageLocalID int 
	,@LegalPageBody ntext
	,@UpdatedBy nvarchar(255)
)
as

/*
	This stored procedure update LegalPagesLocal table for particular LegalPageLocalID
	
	Content owned by India team,
    please notify asaxena@opentable.com if changing.
*/

	update
		[LegalPagesLocal]
	set
		 [LegalPageBody] = @LegalPageBody
		,[UpdatedBy] = @UpdatedBy
		,[UpdateDateTSUTC] = GETUTCDATE()
	where
		[LegalPageLocalID] =@LegalPageLocalID and
		[LanguageID] = [LanguageID]
go

grant execute on [Admin_UpdateLegalPageForID] to ExecuteOnlyRole

go



