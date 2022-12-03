class SqlParameterBuilder
{
    $Result = '';
    $Tokens = @{
        Parameter = "@{0}=`'`${0}`', "
    }
    [string] Get() {
        $temp= $this.Result.Trim(", ")
        $temp = [string]::Format($this.Tokens.Block, $temp)
        return $temp;
    }
    [void]Add([string]$item) {
        $this.Result += [string]::Format($this.Tokens.Parameter, $item)
    }
}
