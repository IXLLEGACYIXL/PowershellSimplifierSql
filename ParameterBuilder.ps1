
class ParameterBuilder {
    $Result = '';
    $Tokens = @{
        Parameter = "`t[Mandatory=`$false]`n`t[{0}] `${1},`n"
        Block     = "[CmdletBinding()]`nparam`n(`n{0}`n)"
    }
    [string] Get() {
        $temp= $this.Result.Trim(",`n")
        $temp = [string]::Format($this.Tokens.Block, $temp)
        $this.Result = '';
        return $temp;
    }
    [void]Add([string]$type, [string]$item) {
        $this.Result += [string]::Format($this.Tokens.Parameter, $this.ConvertSqlTypeToCsharpType($type), $item)
    }
    [void]AddDbProvider($dbProvider) {
        $this.Result += "`t[string] `$Instance = `"" + $dbProvider.ServerInstance + "`",`n"
        $this.Result += "`t[string] `$Database = `"" + $dbProvider.Database + "`",`n"
    }
    [string] ConvertSqlTypeToCsharpType([string] $type) {
        $typer = switch ($type) {
            { @("timestamp", "filestream", "rowversion", "varbinary", "binary", "image") -contains $_ } { "Byte[]" }
            "tinyint" { "byte" }
            "smallint" { "short" }
            "int" { "int" }
            "bigint" { "long" }
            "float" { "double" }
            "real" { "float" }           
            "xml" { "xml" }
            { @("datetime2", "datetime") -contains $_ } { "System.Data.SqlTypes.SqlDateTime" }
            { @("varchar", "nvarchar", "smalldatetime", "datetime", "datetime2", "date") -contains $_ } { "string" }
            { @("char", "nchar") -contains $_ } { "char[]" }
            "uniqueidentifier" { "Guid" }
            "bit" { "boolean" }
            "time" { "TimeSpan" } 
            { @("money", "numeric", "smallmoney", "decimal") -contains $_ } { "Decimal" }     
            "datetimeoffset" { "DateTimeOffset" }
            "sql_variant" { "object" }
            "geography" { "Microsoft.SqlServer.Types.SqlGeography" }
            "geometery" { "Microsoft.SqlServer.Types.SqlGeometry" }
            "hierarchyid" { "Miscrosoft.SqlServer.Types.SqlHierarchyId" }
            Default { "object" }
        };
        return $typer
    }
}


$testParameterBuilder = [ParameterBuilder]@{}

$testParameterBuilder.Get()
$testParameterBuilder.AddDbProvider(@{
    ServerInstance = "MS110\DEV"	    
    Database = "DEV"
});
$testParameterBuilder.Get();


$testParameterBuilder.AddDbProvider(@{
    ServerInstance = "MS110\DEV"
    Database = "DEV"
});
$testParameterBuilder.Add("nvarchar","chartable")
$testParameterBuilder.Get()