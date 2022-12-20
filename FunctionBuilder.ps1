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
    [void] CreateFunction(){
        Write-Host "CREATE: $($this.GetFunctionName())"
        Set-Item -Path $this.GetFunctionName() -Value $this.GetCodeBlock()
    }
    [string] GetFunctionName()
    {
        return "function:global:$($this.ProcedureName)`_$($this.Schema)`_$($this.Database)"
    }
}