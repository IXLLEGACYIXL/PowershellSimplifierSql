<#
    This base class defines the minimum Requirements for a DatabaseProvider.
    The Class should be able to:
        - Invoke Querys.
        - Find Procedures from the Server with its information.
        - Deliver an Invocation String for other classes to use.
#>
class DatabaseProvider {
    # Invokes a SQL Query.
    [object[]] InvokeQuery([string]$Query) {
        throw "Method InvokeQuery was not overriden."
    }
    # Searches in the SQL Server for Procedures and returns them.
    [object[]] GetProcedures() {
        throw "Method GetProcedures was not overriden."
    }
    # Returns the Invocation string for other classes to be able to add it to a function.
    [string] GetInvocationString() {
        throw "Method GetInvocationString was not overriden."
    }
    [string] GetProcedureCode($Name) {
        throw "Method GetProcedureCode was not overriden."
    }
    [object[]] ExtractDescription($ProcedureCode){
        throw "Method ExtractDescription was not overriden."
    }
    [string] ExtractSynopsis([object[]] $ProcedureCode )
    {
        throw "Method ExtractSynopsis was not overriden."
    }
}
class SqlServerProvider : DatabaseProvider {
    [string]$ServerInstance
    [string]$Database
    SqlServerProvider([string]$ServerInstance, $Database) {
        $this.ServerInstance = $ServerInstance
        $this.Database = $Database
    }
    [object[]] InvokeQuery([string]$Query) {
        Write-Host $this.ServerInstance $this.Database
        return Invoke-Sqlcmd -Database $this.Database -ServerInstance $this.ServerInstance -Query $Query -OutPutAs DataTables  -ErrorAction Stop
    }
    [string] GetInvocationString() {
        return "Invoke-Sqlcmd -Database $($this.Database) -ServerInstance $($this.ServerInstance) -Query {0}"
    }
    [object[]] GetProcedures() {
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
    [object[]] GetProcedureCode($Name) {
        return $this.InvokeQuery("EXEC sp_helptext '$Name'");
    }
    [string] ExtractDescription([object[]] $ProcedureCode )
    {
        $DELIMITER = "`n"
        $START = "`t"
        $result = '';
        foreach($line in $ProcedureCode){
            [string]$line = $line;
            if($line.StartsWith("--")){
                $result += $START + $line.Trim().TrimStart("--").TrimStart() + $DELIMITER
            }else{
                break;
            }
        }
        return $result.TrimEnd($DELIMITER);
    }
    [string] ExtractSynopsis([object[]] $ProcedureCode )
    {
        $DELIMITER = "`n"
        $START = "`t"
        foreach($line in $ProcedureCode){
            [string]$line = $line;
            if($line.StartsWith("-- Description")){
                return $START + $line.Trim().TrimStart("-- Description:").TrimStart() + $DELIMITER
            }
        }
        return '';
    }
} 