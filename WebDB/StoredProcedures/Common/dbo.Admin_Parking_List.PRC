if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Parking_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Parking_List]
GO

CREATE Procedure dbo.Admin_Parking_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		ParkingID AS ParkingID
			,Parking as Value
FROM		ParkingVW

GO

GRANT EXECUTE ON [Admin_Parking_List] TO ExecuteOnlyRole

GO
