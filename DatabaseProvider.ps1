class SqlServerProvider : DatabaseProvider
{
    [string]$ServerInstance
    [string]$Database
    SqlServerProvider([string]$ServerInstance,$Database){
        $this.ServerInstance = $ServerInstance
        $this.Database = $Database
    }
    [object[]] InvokeQuery([string]$Query)
    {
        Write-Host $this.ServerInstance $this.Database
        return Invoke-Sqlcmd -Database $this.Database -ServerInstance $this.ServerInstance -Query $Query -OutPutAs DataTables  -ErrorAction Stop
    }
    [string] GetInvocationString(){
        return "Invoke-Sqlcmd -Database $($this.Database) -ServerInstance $($this.ServerInstance) -Query {0}"
    }
    [object[]] GetProcedures(){
        return $this.InvokeQuery("
        SELECT 
            [Parameter] = STRING_AGG([Params].[name],';'),
            [Schema]    = SCHEMA_NAME([Proced].[schema_id]),
            [Name]      = [Proced].[Name],
            [Type]      = STRING_AGG(type_name([Params].[user_type_id]),';')
        FROM
            [sys].[parameters]    AS [Params]
            RIGHT JOIN
                [sys].[Procedures] AS [Proced] 
            ON
                [Params].[object_id] = [Proced].[object_id]
        GROUP BY
            [Proced].[name],
            [Proced].[schema_id]
        ");
    }
} 
class DatabaseProvider
{
    [object[]] InvokeQuery([string]$Query)
    {
        throw "Method InvokeQuery was not overriden."
    }
    [object[]] GetProcedures(){
        throw "Method GetProcedures was not overriden."
    }
    [string] GetInvocationString(){
        throw "Method GetInvocationString was not overriden."
    }

}