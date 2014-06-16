if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Neighborhood_Add2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Neighborhood_Add2]
GO

--********************************
--** TODO: CVS NOTES: Improved error handling / reporting
--**		Consider add prefix to Master Record inserts
--********************************


CREATE PROCEDURE dbo.Admin_Neighborhood_Add2
 (
  @Name nvarchar(50),
  @SName nvarchar(50),
  @Active bit,
  @GeoID int,
  @Macroid int
 )
As

set nocount on

BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @ID int


set @ProcName = 'Admin_Neighborhood_Add2'

--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID
set @DBError = @@error
if @DBError <> 0
	goto general_error


--**********************
--** Insert into Master Table
--**********************
set @Action = 'INSERT INTO Neighborhood'

INSERT INTO Neighborhood(
	Active,
	metroareaid,
	MacroID
)
VALUES (
	@Active,
	@GeoID,
	@Macroid
)
set @DBError = @@error
if @DBError <> 0
	goto general_error

set @ID = scope_identity()

--**********************
--** Insert into local Table for all Languages Metro Exists
--**********************
set @Action = 'INSERT INTO Neighborhoodlocal'

INSERT INTO NeighborhoodLocal(
	NeighborhoodID,
	LanguageID,
	NbHoodName,
	NbhoodSName
)
SELECT 	@ID,
	LanguageID,
	@Name,
	rtrim(ltrim(@SName))
FROM 	Metroarealocal
WHERE 	MetroareaID = @GeoID

set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRANSACTION
Return(0)

no_active_macroneighborhood:
	ROLLBACK TRANSACTION
	Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO

GRANT EXECUTE ON [Admin_Neighborhood_Add2] TO ExecuteOnlyRole

GO
