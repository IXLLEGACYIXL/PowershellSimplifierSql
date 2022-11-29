class SqlParameterBuilder
{
    $Result = '';
    $Tokens = @{
        Parameter = "@{0}=`'`${0}`', "
    }
    [string] Get() {
        $temp= $this.Result.Trim(", ")
        $temp = [string]::Format($this.Tokens.Block, $temp)
        $this.Result = '';
        return $temp;
    }
    [void]Add([string]$item) {
        $this.Result += [string]::Format($this.Tokens.Parameter, $item)
    }
}
$testSqlParameterBuilder = [SqlParameterBuilder]@{}

$testSqlParameterBuilder.Get();

$testSqlParameterBuilder.Add("chartable")
$testSqlParameterBuilder.Get()
$testSqlParameterBuilder = [SqlParameterBuilder]@{}

$testSqlParameterBuilder.Get();

$testSqlParameterBuilder.Add("chartable")
$testSqlParameterBuilder.Add("chartable2")
$testSqlParameterBuilder.Add("chartable3")
$testSqlParameterBuilder.Get()