if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_GetConsumerTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_GetConsumerTypes]
GO






CREATE Procedure dbo.Admin_Promos_GetConsumerTypes

As

Select 	ConsumerTypeID as Consumer_Type_ID, 
	ConsumerTypeTypeName as TypeName 
from 	ConsumerTypes

GO

GRANT EXECUTE ON [Admin_Promos_GetConsumerTypes] TO ExecuteOnlyRole

GO
