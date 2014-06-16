

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_GetAllResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_GetAllResos]
GO





CREATE PROCEDURE dbo.DBD_GetAllResos
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select count(ResID) as resos,
sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers,
datePart(dd,DateMade) as dateday,
datePart(month,DateMade) as datemonth,datePart(year,DateMade) as dateyear
from Reservation 
where RStateID not in (3,4,8,9,10) and dateMade > getdate()-730
group by datePart(dd,DateMade),datePart(month,DateMade),datePart(year,DateMade)
order by datePart(year,DateMade),datePart(month,DateMade),datePart(dd,DateMade)


GO

GRANT EXECUTE ON [DBD_GetAllResos] TO ExecuteOnlyRole

GO
