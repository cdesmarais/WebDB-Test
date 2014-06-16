if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminGetDiningForms]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminGetDiningForms]
GO


-- Get all versions of dining forms..
CREATE PROCEDURE dbo.AdminGetDiningForms

AS

-- get dining form data..
select diningformid,active,lastchgby,lastupddatets,pointsawarded from diningform

GO

GRANT EXECUTE ON [AdminGetDiningForms] TO ExecuteOnlyRole

GO
