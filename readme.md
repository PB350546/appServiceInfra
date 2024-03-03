
# AppService Infra Setup


## About : 

This project enables users to deploy Appservice on their Azure environment. The project is based on infrastructure as a code (IaaC).

## Structural definition of the project :
- **templates**: This folder consist of the bicep template corresponding to Appseervice code.
- **parameters** : This folder contains the parameter files per environment used by the bicep template to generate the web app.
- **pipelines** : This folder consist of the deployment pipeline that is responsible for creation of the web app.
- **variables** : This folder contains the global varaibles which are not restricted to type of resource and are specific to per environment.

## How to create app service (web app) infra : 
- Create the pipeline in Azure DevOps.
- Run the pipeline: You need to select the environment and provide the name of app to be created.

## Diagram : 

![digram](app-service.jpg)

## Security : 
 - RBAC (Role based access control): 
    - IAM (Identity and Management): Using Microsoft Entra Id (AAD) we can manage access to app service based on roles.
    - Using managed identity we can manage app service access to other azure resources like storage account, Databases without using password.
- We can restrict network access to app service using Azure virtual network (Vnet). Inbound traffic can be controlled using private endpoint link (PLE) with PLE subnet NSG (Network security group) and Outbound traffic can be controlled using app service vnet integration. Using this we can make traffic to traverse via secured private network instead of public internet.

## FAQ's :  
- Your Service experiences irregular peak load, how do you address this? 
  - We can solve this issue by using auto scale feature in Appservice.
  - Autoscale can be configured based on cpu usage, memory usage also based on peak hours.

- How do you perform a running deployment without downtime? 
    - We can make use of Blue Green deployment methodology.
    - This can be achieved by using slots in Appservice.

- How do you handle production monitoring?
    - We can use Azure Monitor feature for monitoring and logging purpose of Appservice.
    - Appinsignts can be configured to view and analyze logs.
    - You can also configure azure alerts based on metrics and custom logs. 

- How do you deal with errors?
    - We can inspect the pipeline logs in case of failure and figure out the root cause.
    - This can differ for multiple failure causes.

## Remark : 

This project is extendable and reusable depending on the project requirements.