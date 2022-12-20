class SqlParameterBuilder
{
    hidden [string]$Result = '';
    hidden [string]$Parameter;

    SqlParameterBuilder([string]$ParmeterConfig){
        $this.Parameter = $ParmeterConfig;
    }
    [string] Get() {
        $temp= $this.Result.Trim(", ")
        $temp = [string]::Format($this.Tokens.Block, $temp)
        return $temp;
    }
    [void]AddAll([string]$items){
        $items | Foreach-object { $this.Add($_); }
    }
    [void]Add([string]$item) {
        $this.Result += [string]::Format($this.Parameter, $item)
    }
}
