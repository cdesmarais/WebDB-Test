if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Company_Top10]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Company_Top10]
GO

CREATE PROCEDURE dbo.Report_Company_Top10
(
  @metroID int,
  @thrudate Datetime = Null
)
AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Declare @fromdate datetime
, @header nvarchar(50)

If @thrudate is null
	Begin
	Select @thrudate = Cast(convert(nvarchar, getdate(), 101) as datetime) --get request(current) date to range
	End

Select @fromdate = dateadd(d,-7,Cast(@thrudate as datetime)) --get request date from range
Select @header = Cast(@fromdate as nvarchar)+' - '+Cast(@thrudate as nvarchar(50))

Select top 10 (OTComp.CompanyName + '(' + convert(nvarchar,TopList.Resos) + ')') as Company
, @header as date_range
From CompanyTopList TopList
inner join Company OTComp 
on TopList.CompanyID = OTComp.CompanyID
where OTComp.MetroAreaID = @metroID
Order by TopList.Resos desc

GO


GRANT EXECUTE ON [Report_Company_Top10] TO ExecuteOnlyRole

GO
