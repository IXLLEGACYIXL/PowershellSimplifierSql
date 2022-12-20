class CodeBlockBuilder
{
    hidden $SqlParameter;
    hidden $ProcedureName;
    hidden $TOKENS =@{
        Block = "Invoke-SqlCmd -ServerInstance `$Instance -Database `$Database -Query `"EXEC {0} {1}`""
    }
    CodeBlockBuilder($SqlParams,$Procedure){
        this.SqlParameter = $SqlParams;
        this.$ProcedureName = $Procedure;
    }
    [string] Get()
    {
        return [string]::Format($this.TOKENS.Block,$this.ProcedureName, $this.SqlParameter)
    }
}


