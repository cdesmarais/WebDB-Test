if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Callers_TotalPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Callers_TotalPoints]
GO
 
CREATE Procedure dbo.Admin_Callers_TotalPoints  
(    
  @CompanyID nvarchar(10)  
  ,@strRID nvarchar(4000)  
)    
As    
SET NOCOUNT ON    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED     

--Pending, seated, assumed seated, seated disputed (1,2,5,7)
  
 SELECT		ca.callerid as ConciergeID    
			,ca.fname + ' ' + ca.lname as ConciergeName    
			,coalesce(ca.points, 0)	 'Current Points' 
			,coalesce(SUM(r.respoints), 0) 'Points from Restaurants'    
			,case when max(ca.points) < sum(r.respoints) then ca.points  
			else sum(r.respoints) end  'Adjustment'    	
			,(	SELECT	COALESCE(SUM(PointsRedeemed),0) 
				FROM	giftredemption 
				where	ca.CallerID = giftredemption.CallerID
			) as 'Points Redeemed' 
 FROM		caller ca   
 INNER JOIN reservation r  
 on			r.callerid = ca.callerid   
 INNER JOIN fStringsToTab(@strRID, ',') as selectedRID  
 on			selectedRID.StringValues = r.RID  
 WHERE		ca.companyid = @CompanyID   
 AND		r.rstateid in (1, 2, 5, 7) 
 group by	ca.callerid
			,ca.points
			,ca.fname
			,ca.lname  
  
GO

GRANT EXECUTE ON [Admin_Callers_TotalPoints] TO ExecuteOnlyRole

GO
