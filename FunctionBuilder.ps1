class FunctionBuilder
{
    $Schema
    $ProcedureName
    $Database
    $Instance
    $ParameterBlock
    $ParameterChecks
    $AdditionalCodeBlock
    $SqlQuery
    $EndBlock
    [string] GetCodeblock(){
        return $this.ParameterBlock + $this.ParameterChecks + $this.AdditionalCodeBlock + $this.SqlQuery + $this.EndBlock
    }
    [string] GetFunctionName()
    {
        return "function:global:$($this.ProcedureName)`_$($this.Schema)`_$($this.Database)"
    }
}