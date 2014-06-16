***************
INTENDED USE:
***************
This folder is intended to contain stored procedures related to reports.
Procs that fall into this folder will typically be "Job" related procs that are used to extract and/or report data. These procs will typically be called from DTS, SSIS, or a DB Job. 


*************
Owners
*************
DBA and Infrastructure group are the primary owners of this folder. However, other parties that need to create a report may use this folder provided they review it with DBA / Infra first.


************
Deployment
************
Procs contained in this folder will be deployed manually outside of the Consumer Web Deployment.
Deployment will be performed by DBA or by Deployment Engineer

**Deployment will only be performed from the TRUNK. Developers may develop on a branch but must merge to trunk prior to deployment.



