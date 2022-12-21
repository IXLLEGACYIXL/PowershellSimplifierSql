function Global:Import-StoredProcedures
{
    [CmdletBinding()]
    param([string]$ServerInstance,[string]$Database)

    # Import Classes
    . .\DatabaseProvider.ps1
    . .\CodeBlockBuilder.ps1
    . .\FunctionBuilder.ps1
    . .\ParameterBuilder.ps1
    . .\SqlParameterBuilder.ps1
    . .\SynopsisBuilder.ps1


    [DatabaseProvider]$DBProvider = [SqlServerProvider]::new($ServerInstance,$Database);
    [SynopsisBuilder]$SynopsisBuilder = [SynopsisBuilder]::new();
    foreach ($item in $DBProvider.GetProcedures()) 
    {
        
        $SqlParameterBuilder = [SqlParameterBuilder]::new("@{0}=`'`${0}`', ",", ");
        
        $ParameterBlockBuilder = [ParameterBuilder]::new();
    
        $ParameterBlockBuilder.AddDbProvider($DBProvider);
        
        if( "$($item.Parameter)" -ne '' )
        {
            $SplittedParameter = ([string]$item.Parameter).Replace("@",'').Split(';');
            $SplittedTypes = ([string]$item.Type).Split(';');
            
            $SqlParameterBuilder.AddAll([string]$SplittedParameter)
            
            $ParameterBlockBuilder.AddAll($SplittedTypes,$SplittedParameter);
            $SynopsisBuilder.AddAllParameter($SplittedParameter,$SplittedTypes);
        }
        $ProcedureName = "$($item.Schema)`.$($item.Name)";
        $CodeBlockBuilder = [CodeBlockBuilder]::new($DBProvider.GetInvocationString(),$SqlParameterBuilder.Get() +" " +$ProcedureName);
        
        $FunctionBuilder = [FunctionBuilder]@{    
            SqlQuery = $CodeBlockBuilder.Get()
            Schema = $item.Schema
            ProcedureName = $item.Name
            ParameterChecks = ''
            ParameterBlock = $($ParameterBlockBuilder.Get()+ "`n" + $SynopsisBuilder.Get())         
            Instance = $DBProvider.ServerInstance
            Database = $DBProvider.Database
        }
        
        $FunctionBuilder.CreateFunction();
    }
}
