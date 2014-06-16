if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAddRestFinderLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAddRestFinderLog]
GO

-- Add record to RestFinderLog
CREATE PROCEDURE dbo.DNAddRestFinderLog
(
		@SearchWords nvarchar(100),
		@MetroID int,
		@PossibleMatchList nvarchar(4000),
		@ExactMatchList nvarchar(1000),
		@NumMatches int,
		@InShowGroup bit=false,
		@NotInShowGroup bit=false
)

AS

--********************************
--** This proc has been changed to do nothing since it's an expensive / frequent write operation
--** EV: 01/10/2008
--** TODO: Obosolete caller of this proc
--********************************

-- perform insert into RestFinderLog
--insert into RestFinderLog(DateTS,SearchWords,MetroID,PossibleMatchList,ExactMatchList,NumMatches,InShowGroup,NotInShowGroup)
--values(getdate(),@SearchWords,@MetroID,@PossibleMatchList,@ExactMatchList,@NumMatches,@InShowGroup,@NotInShowGroup)

GO

GRANT EXECUTE ON [DNAddRestFinderLog] TO ExecuteOnlyRole

GO
