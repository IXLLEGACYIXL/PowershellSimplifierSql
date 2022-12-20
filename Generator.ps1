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
    $ProcedureSearchQuery = $DBProvider.GetProcedures();
    . .\CodeBlockBuilder.ps1
    . .\FunctionBuilder.ps1
    . .\ParameterBuilder.ps1
    . .\SqlParameterBuilder.ps1

    foreach ($item in $DBProvider.InvokeQuery($ProcedureSearchQuery)) 
    {
        $SqlParameterBuilder = [SqlParameterBuilder]::new();
        
        $ParameterBlockBuilder = [ParameterBuilder]::new();
    
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
        }
        $ProcedureName = "$($item.Schema)`.$($item.Name)";
        $CodeBlockBuilder = [CodeBlockBuilder]::new($SqlParameterBuilder.Get(),$ProcedureName);
        
        $FunctionBuilder = [FunctionBuilder]@{    
            SqlQuery = $CodeBlockBuilder.Get()
            Schema = $item.Schema
            ProcedureName = $item.Name
            ParameterChecks = ''
            ParameterBlock = $ParameterBlockBuilder.Get()            
            Instance = $DBProvider.ServerInstance
            Database = $DBProvider.Database
        }
        
        $FunctionBuilder.CreateFunction();
    }
}
