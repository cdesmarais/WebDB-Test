

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetDinersChoiceWinnerListUpdateDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetDinersChoiceWinnerListUpdateDate]
GO

create procedure dbo.DNGetDinersChoiceWinnerListUpdateDate
as

/*
--** This stored procedure is used to retrieve the date when the Diners' Choice Winners
--** list was last updated.
--** This proc is called from OTRestaurant (dcw.aspx page) that displays the 
--** Diners' Choice Winners List
--** Content owned by India team, please notify asaxena@opentable.com if changing.
--** There will be only one record in the table that has status as active (i.e Status = 1)
*/

select	
	CreateDate
from
	TopTenImportJob
where
	Status = 1

GO

GRANT EXECUTE ON [DNGetDinersChoiceWinnerListUpdateDate] TO ExecuteOnlyRole

GO

