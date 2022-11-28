class CodeBlockBuilder
{    
    $Instance;
    $Database;
    $SqlParameter;
    $Tokens =@{
        Block = "Invoke-SqlCmd -ServerInstance {0} -Database {1} -Query `"{2}`""
    }

    [string] Get()
    {
        return [string]::Format($this.Tokens.Block, $this.Instance,$this.Database,$this.SqlParameter)
    }
}


