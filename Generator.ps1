class DatabaseProvider
{
    $ServerInstance
    $Database
    
    [object[]] InvokeQuery([string]$Query)
    {
        return Invoke-Sqlcmd -Database $this.ToolDB -ServerInstance $this.ToolServer -Query $Query -OutPutAs DataTables  -ErrorAction Stop
    }
}
. .\CodeBlockBuilder.ps1
. .\FunctionBuilder.ps1
. .\ParameterBuilder.ps1
. .\SqlParameterBuilder.ps1
$ProcedureSearchQuery = "
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

function CollectProcedures
{
    [CmdletBinding()]
    param($ServerInstance,$Database)
    $DBProvider = [DatabaseProvider]@{
        ServerInstance = $ServerInstance
        Database = $Database
    }
    $SqlParameterBuilder = [SqlParameterBuilder] @{}

    $ParameterBlockBuilder = [ParameterBuilder] @{}

    $ParameterBlockBuilder.AddDbProvider($DBProvider);

    foreach ($item in $DatabaseProvider.InvokeQuery($ProcedureSearchQuery)) 
    {
        if($item.Parameter)
        {
            $SplittedParameter = $item.Parameter.Split(';');
            $SplittedTypes = $item.Type.Split(';');
            
            
            for($i = 0; $i -lt $SplittedParameter.Length;$i++)
            {
                $SqlParameterBuilder.Add($SplittedParameter[$i]);
                $ParameterBlockBuilder.Add($SplittedTypes[$i],$SplittedTypes[$i]);
            }
            
        
        }
    }
    $CodeBlockBuilder = [CodeBlockBuilder]@{
        SqlParameter = $SqlParameterBuilder.Get()
        Instance = $DBProvider.ServerInstance
        Database = $DBProvider.Database
    }
    $FunctionBuilder = [FunctionBuilder]@{
        
        SqlQuery = $CodeBlockBuilder.Get()
        Schema = $item.Schema
        ProcedureName = $item.Name
        ParameterChecks = ''
        ParameterBlock = $ParameterBlockBuilder.Get()
        
        Instance = $DBProvider.ServerInstance
        
        Database = $DBProvider.Database
    }
    $FunctionName = $FunctionBuilder.GetFunctionName()
    $CodeBlock = $FunctionBuilder.GetCodeblock();
    Write-Host ""+$FunctionName "" + $CodeBlock
    #   Set-Item -Path $FunctionName -Value $CodeBlock

}