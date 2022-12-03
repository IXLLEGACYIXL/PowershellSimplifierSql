# PowershellSimplifierSql
License: MIT

Only Compatible for SQL-Server ( Windows MSSQL Server )

Call
.\Generator

Then you have the CollectProcedures Function which needs a Server Instance ( also Cluster are possible ) and a Database
CollectProcedures -ServerInstance "MS110\DEV" -Database "SqlDataTools"

Then your procedure Connections are available.
Following the naming conventions in your SQL Server, by adding sp_ infront will lead to that function naming.
If your Procedures dont start with sp_ then you will find your Functions by Following that pattern {PROCEDURE_NAME}_{SCHEMA}
![grafik](https://user-images.githubusercontent.com/107197024/205459704-5b806b93-e596-4311-b4ba-9ef667b797d1.png)
