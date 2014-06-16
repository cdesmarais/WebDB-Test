


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPointsAdjustmentHistByCustID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetPointsAdjustmentHistByCustID]
GO

create procedure dbo.GetPointsAdjustmentHistByCustID
(   
  @CustomerID int,  
  @IsCaller int  
)
AS   

/******************************************************************
Purpose: Get the history of Points adjustment for a customer/caller
		 to display on CHARM points adjustment history tracking grid.
*******************************************************************/  
if @IsCaller = 0 
begin
	-- Get history from points adjustment table for customer. 

	select 
		pta.AdjustmentAmount,
		case 
			WHEN ptar.CHARMExplanation = 'Other' THEN Coalesce(pta.AdjusterOtherReason,'')
			Else ptar.CHARMExplanation
		end as CHARMExplanation,
		pta.AdjustmentDate,
		pta.AdjusterCharmUserEmail,
		pta.AdjReasonID
	from 
		pointsadjustment pta
		inner join
		pointsadjustmentreason ptar
		on pta.AdjReasonID = ptar.AdjReasonID
	where  
		pta.custid = @CustomerID 
	order by 
		pta.AdjustmentDate desc
end   
if @IsCaller > 0 
begin 
	-- Get history from points adjustment table for caller.
	select 
		pta.AdjustmentAmount,
		case 
			WHEN ptar.CHARMExplanation = 'Other' THEN Coalesce(pta.AdjusterOtherReason,'')
			Else ptar.CHARMExplanation
		end as CHARMExplanation,
		pta.AdjustmentDate,
		pta.AdjusterCharmUserEmail,
		pta.AdjReasonID
	from 
		pointsadjustment pta
		inner join
		pointsadjustmentreason ptar
		on pta.AdjReasonID = ptar.AdjReasonID
	where  
		pta.callerid = @CustomerID
	order by 
		pta.AdjustmentDate desc
		
end  

GO

GRANT EXECUTE ON [GetPointsAdjustmentHistByCustID] TO ExecuteOnlyRole
GO