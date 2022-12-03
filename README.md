# PowershellSimplifierSql
License: MIT

Only Compatible for SQL-Server ( Windows MSSQL Server )

Call
.\Generator

Then you have the CollectProcedures Function which needs a Server Instance ( also Cluster are possible ) and a Database
CollectProcedures -ServerInstance "MS110\DEV" -Database "SqlDataTools"

Then your procedure Connections are available.
Following the naming conventions in your SQL Server, by adding sp_ infront will lead to that function naming.
If your Procedures dont start with sp_ then you will find your Functions by Following that pattern {PROCEDURE_NAME}_{SCHEMA}_{DATABASE}

you can collect from multiple different databases, but collecting from same database names will overwrite the old functions if they end up with the same name, no check available if the function exists



![grafik](https://user-images.githubusercontent.com/107197024/205459860-48362813-1410-4ec4-9ee4-7580d00d3cd4.png)

