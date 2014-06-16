***************
INTENDED USE:
***************
This folder is intended to contain stored procedures related to Operations. 
Primarily Procs need for Nagios and Monitoring.
These procs are not called by the consumer website. They are either called through jobs,  directly from Nagios, or called directly from some other operations tool.

*************
Owners
*************
DBA and Infrastructure group are the primary owners of this folder. However, other parties that need to create an operations related proc may use this folder provided they review it with DBA / Infra first.


************
Deployment
************
Procs contained in this folder will be deployed manually outside of the Consumer Web Deployment.
Deployment will be performed by DBA or by Deployment Engineer

**Deployment will only be performed from the TRUNK. Developers may develop on a branch but must merge to trunk prior to deployment.




