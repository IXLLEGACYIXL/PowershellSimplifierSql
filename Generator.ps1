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
    [SqlParameterBuilder]$SqlParameterBuilder = [SqlParameterBuilder]::new("@{0}=`'`${0}`', ",", ");
    foreach ($item in $DBProvider.GetProcedures()) 
    {
        $ProcedureName = "$($item.Schema)`.$($item.Name)";
        
        
        $ParameterBlockBuilder = [ParameterBuilder]::new();
    
        $ParameterBlockBuilder.AddDbProvider($DBProvider);
        
        $ProcedureCode = $DBProvider.GetProcedureCode($ProcedureName).Text;
        
        $Description = $DBProvider.ExtractDescription($ProcedureCode);
        $Synopsis = $DBProvider.ExtractSynopsis($ProcedureCode);
        $SynopsisBuilder.AddDescription($Description);
        $SynopsisBuilder.AddSynopsis($Synopsis);
        if( "$($item.Parameter)" -ne '' )
        {
            $SplittedParameter = ([string]$item.Parameter).Replace("@",'').Split(';');
            $SplittedTypes = ([string]$item.Type).Split(';');
            
            $SqlParameterBuilder.AddAll([object[]]$SplittedParameter)
            
            $ParameterBlockBuilder.AddAll($SplittedTypes,$SplittedParameter);
            $SynopsisBuilder.AddAllParameter($SplittedParameter,$SplittedTypes);
        }
        
        $CodeBlockBuilder = [CodeBlockBuilder]::new($DBProvider.GetInvocationString(),"EXEC $ProcedureName "+$SqlParameterBuilder.Get());
        
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
