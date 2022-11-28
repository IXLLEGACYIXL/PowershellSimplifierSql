class DatabaseProvider
{
    $ServerInstance
    $Database
    [object[]] InvokeQuery([string]$Query)
    {
        return Invoke-Sqlcmd -Database $this.ToolDB -ServerInstance $this.ToolServer -Query $Query -OutPutAs DataTables  -ErrorAction Stop
    }
}
$StringMap = @{
    DBProvider = "`n`t[DatabaseProvider]`$DatabaseProvider"
    DBProviderNullPointer = "if(-Not `$DatabaseProvider) { throw `"The DatabaseProvider is Null`" }"
    FunctionName = "function:global:{0}`_{1}`_{2}"
    Delimiter = ';'
    SQLParam = "@{0}='`${0}' ,"
    SQLParamTrim = " ,"
    Param = ",`n`t{0} `${1}"
    ParamBlock = "[CmdletBinding()]`nparam`n({0}`n)`n"
    SqlVariableToken = '@'
    Type= "[{0}]"
    GeneratedFunction = "# Generated Function`n`t{0}"
    ProcedureSearchQuery = "
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
    "
    Code = "`n`$DataBaseProvider.InvokeQuery(`"EXEC {0}.{1} {2}`")"
}
function CollectProcedures
{
    [CmdletBinding()]
    param([DatabaseProvider]$DatabaseProvider)
    foreach ($item in $DatabaseProvider.InvokeQuery($StringMap.ProcedureSearchQuery)) 
    {
        $Parameters = $StringMap.DBProvider;
        
        $SqlParameters = '';
        $tempParameters = $item.Parameter
        
        if([string]$tempParameters)
        {
            $SqlParameter =  $tempParameters.Replace($StringMap.SqlVariableToken,'').Split($StringMap.Delimiter);
            
            $Types = $item.Type.Split($StringMap.Delimiter)

            for($i = 0; $i -lt $SqlParameter.Length;$i++)
            {
                $shortParameter = $SqlParameter[$i]
                Write-Verbose $shortParameter
                $Parameters += [string]::Format($StringMap.Param,(ConvertSqlTypeToCsharpType -type $types[$i]),$shortParameter)
                $SqlParameters += [string]::Format($StringMap.SQLParam,$shortParameter) 
            }
            $SqlParameters.TrimEnd($StringMap.SQLParamTrim) >> Out-Null
        }
        Write-Verbose "## START: $($item.Name)"
        
        $ParameterBlock = [string]::Format($StringMap.ParamBlock, $Parameters)
        Write-Verbose "ParameterBlock: $ParameterBlock"

        $ParameterCheck = $StringMap.DBProviderNullPointer;
        Write-Verbose "ParameterCheck: $ParameterCheck"

        $Code = [string]::Format($StringMap.Code,$item.Schema,$item.Name,$SqlParameters)
        Write-Verbose $("Codeblock:`n" + $Code)

        $FunctionName = [string]::Format($StringMap.FunctionName,$item.Name,$item.Schema,$DatabaseProvider.ToolDB) 
        Write-Verbose "FunctionName: $FunctionName"
        
        $GeneratedFunction = $ParameterBlock+$ParameterCheck+$Code
        Write-Verbose $("GeneratedFunction:"+ $GeneratedFunction)

        Set-Item -Path $FunctionName -Value $GeneratedFunction
        Write-Verbose "StoredFunction:`n$($(Get-Item "Function:\$($item.Name)`_$($item.Schema)`_$($DataBaseProvider.ToolDB)").ScriptBlock)"

        Write-Verbose "## END: $($item.Name)"
    }
}
function ConvertSqlTypeToCsharpType([string] $type)
{
    $result = switch ($type) 
    {
        { @("timestamp","filestream","rowversion","varbinary","binary","image") -contains $_ }  { "Byte[]"}
        "tinyint"                                                                    { "byte" }
        "smallint"                                                                   { "short"}
        "int"                                                                        { "int" }
        "bigint"                                                                     { "long" }
        "float"                                                                      { "double" }
        "real"                                                                       { "float" }           
        "xml"                                                                        { "xml" }
        { @("datetime2","datetime") -contains $_ }                                    { "System.Data.SqlTypes.SqlDateTime" }
        { @("varchar","nvarchar","smalldatetime","datetime","datetime2","date") -contains $_ } { "string" }
        { @("char","nchar") -contains $_ }                                           { "char[]" }
        "uniqueidentifier"                                                           { "Guid" }
        "bit"                                                                        { "boolean" }
        "time"                                                                       { "TimeSpan" } 
        { @("money","numeric","smallmoney","decimal") -contains $_ }                 { "Decimal" }     
        "datetimeoffset"                                                             { "DateTimeOffset" }
        "sql_variant"                                                                { "object" }
        "geography"                                                                  { "Microsoft.SqlServer.Types.SqlGeography" }
        "geometery"                                                                  { "Microsoft.SqlServer.Types.SqlGeometry" }
        "hierarchyid"                                                                { "Miscrosoft.SqlServer.Types.SqlHierarchyId" }
        Default                                                                      { "object"}
    };
    return [string]::Format($StringMap.Type,$result)
}