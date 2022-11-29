class CodeBlockBuilder
{
    $SqlParameter;
    $ProcedureName;
    $Tokens =@{
        Block = "Invoke-SqlCmd -ServerInstance `$Instance -Database `$Database -Query `"EXEC {0} {1}`""
    }

    [string] Get()
    {
        return [string]::Format($this.Tokens.Block,$this.ProcedureName, $this.SqlParameter)
    }
}


