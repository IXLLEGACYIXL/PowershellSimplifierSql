class SqlParameterBuilder
{
    hidden $Result = '';
    hidden $Tokens = @{
        Parameter = "@{0}=`'`${0}`', "
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
        $this.Result += [string]::Format($this.Tokens.Parameter, $item)
    }
}
