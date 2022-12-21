class ParameterBuilder {
    hidden $Result = '';
    hidden $TOKENS = @{
        Parameter = "`t[Parameter(Mandatory=`$false)]`n`t[{0}] `${1},`n"
        Block     = "[CmdletBinding()]`nparam`n(`n{0}`n)"
        LineBreak = ",`n"
    }
    [string] Get() {
        $temp= $this.Result.Trim($this.TOKENS.LineBreak)
        $temp = [string]::Format($this.TOKENS.Block, $temp)
        return $temp;
    }
    [void]Add([string]$type, [string]$item) {
        $this.Result += [string]::Format($this.TOKENS.Parameter, $this.ConvertSqlTypeToCsharpType($type), $item)
    }
    [void]AddAll([string[]]$types,[object[]]$items){
        if($types.Length -ne $items.Length){
            throw "Length was not equal:$types , $items"
        }
        for($i = 0; $i -lt $types.Length;$i++)
        {
            Write-HOst $types[$i] $items[$i]
            $this.Add($types[$i],$items[$i]);
        }
    }
    [void]AddDbProvider($dbProvider) {
        $this.Result += "`t[string] `$Instance = `"" + $dbProvider.ServerInstance + "`"" +$this.TOKENS.LineBreak
        $this.Result += "`t[string] `$Database = `"" + $dbProvider.Database + "`"" +$this.TOKENS.LineBreak
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