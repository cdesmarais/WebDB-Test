if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SiteMapXML_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SiteMapXML_Update]
GO

CREATE PROCEDURE dbo.Admin_SiteMapXML_Update
 (
  @DomainID int,
  @XMLFileName NVARCHAR(100),
  @XMLFile NTEXT
 )
As

set nocount on

BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @ID int

set @ProcName = 'Admin_SiteMapXML_Update'
   
if exists ( select * 
   from  SiteMapXML    
   where DomainID = @DomainID  
   and  XmlFileName = @XmlFileName )    
	
Begin
   --******************************
	--** Update SiteMapMXL
	--*****************************		
	set @Action = 'UPDATE SiteMapXML'
	
	UPDATE	SiteMapXML
	SET	XmlFile = @XMLFile,
		FileDate = getDate()	
	where	DomainID = @DomainID  
	and	XmlFileName = @XmlFileName
End
else  
Begin
	--*****************************
	--** Insert into SiteMapMXL
	--*****************************
	set @Action = 'INSERT INTO SiteMapXML'

	INSERT INTO SiteMapXML(
		DomainID,
		XmlFileName,
		XmlFile		
	)
	VALUES (	
		@DomainID,
		@XmlFileName,
		@XmlFile	
	)	
End
	
set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO

GRANT EXECUTE ON [Admin_SiteMapXML_Update] TO ExecuteOnlyRole

GO

