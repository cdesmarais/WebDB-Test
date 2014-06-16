if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePrivateEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePrivateEvents]
go

CREATE PROCEDURE [dbo].[DNCachePrivateEvents]
AS

SELECT pe.PEID, pe.PrivateEventTypeID, HeaderText, pe.MacroID, pt.NAME, m.macroname, m.MetroAreaID
FROM PrivateEvent pe
INNER JOIN PrivateEventType pt ON pt.PrivateEventTypeID = pe.PrivateEventTypeID
inner JOIN MacroNeighborhoodVW m ON m.macroid = pe.macroid

go

GRANT EXECUTE ON [DNCachePrivateEvents] TO ExecuteOnlyRole
GO


