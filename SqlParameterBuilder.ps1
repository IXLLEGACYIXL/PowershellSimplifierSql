class SqlParameterBuilder
{
    hidden [string]$Result = '';
    hidden [string]$Parameter;
    hidden [string]$Delimiter;
    SqlParameterBuilder([string]$ParmeterConfig,[string]$ParameterDelimiter){
        $this.Parameter = $ParmeterConfig;
        $this.Delimiter = $ParameterDelimiter;
    }
    [string] Get() {
        $temp = $this.Result.Trim($this.Delimiter)
        return $temp;
    }
    [void]AddAll([string]$items){
        $items | Foreach-object { $this.Add($_); }
    }
    [void]Add([string]$item) {
        $this.Result += [string]::Format($this.Parameter, $item)
    }
}
