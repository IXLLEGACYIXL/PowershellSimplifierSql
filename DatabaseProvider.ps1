class DatabaseProvider
{
    [string]$ServerInstance
    [string]$Database

    [object[]] InvokeQuery([string]$Query)
    {
        Write-Host $this.ServerInstance $this.Database
        return Invoke-Sqlcmd -Database $this.Database -ServerInstance $this.ServerInstance -Query $Query -OutPutAs DataTables  -ErrorAction Stop
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