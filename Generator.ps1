function Global:CollectProcedures
{
    [CmdletBinding()]
    param($ServerInstance,$Database)
    $DBProvider = [DatabaseProvider]@{
        ServerInstance = $ServerInstance
        Database = $Database
    }
    class DatabaseProvider
    {
        $ServerInstance
        $Database
    
        [object[]] InvokeQuery([string]$Query)
        {
            return Invoke-Sqlcmd -Database $this.Database -ServerInstance $this.ServerInstance -Query $Query -OutPutAs DataTables  -ErrorAction Stop
        }
    } 
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
    . .\CodeBlockBuilder.ps1
    . .\FunctionBuilder.ps1
    . .\ParameterBuilder.ps1
    . .\SqlParameterBuilder.ps1


    foreach ($item in $DBProvider.InvokeQuery($ProcedureSearchQuery)) 
    {
        Write-Verbose "### START"
        $SqlParameterBuilder = [SqlParameterBuilder] @{}
        
        $ParameterBlockBuilder = [ParameterBuilder] @{}
    
        $ParameterBlockBuilder.AddDbProvider($DBProvider);
        
        if( "$($item.Parameter)" -ne '' )
        {
            $SplittedParameter = ([string]$item.Parameter).Replace("@",'').Split(';');
            $SplittedTypes = ([string]$item.Type).Split(';');
            
            
            for($i = 0; $i -lt $SplittedParameter.Length;$i++)
            {
                $SqlParameterBuilder.Add($SplittedParameter[$i]);
                $ParameterBlockBuilder.Add($SplittedTypes[$i],$SplittedParameter[$i]);
            }
            Write-Verbose "PARAMETER_BLOCK: $($ParameterBlockBuilder.Get())"
            Write-Verbose "PARAMETER: $($SqlParameterBuilder.Get())"
        }
        $CodeBlockBuilder = [CodeBlockBuilder]@{
            ProcedureName = "$($item.Schema)`.$($item.Name)"
            SqlParameter = $SqlParameterBuilder.Get()
        }
        Write-Verbose "CODEBLOCK_BUILDER: $($CodeBlockBuilder.Get())"
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
        
        Write-Verbose "FUNCTIONNAME: $FunctionName"
        Write-Verbose "CODEBLOCK: $CodeBlock"
        Set-Item -Path $FunctionName -Value $CodeBlock
        Write-Verbose "### END"
    }
   
   
}
