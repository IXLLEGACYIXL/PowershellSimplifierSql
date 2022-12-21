class SynopsisBuilder
{
    hidden [string]$Result = '';
    [string] Get(){
        return "<#`n" +$this.Result + "#>`n";
    }
    [void] AddSynopsis([string]$value){
        $this.Result += ".SYNOPSIS`n`t$value`n";
    }
    [void] AddDescription([string]$value){
        $this.Result += ".DESCRIPTION`n`t$value`n";
    }
    [void] AddParameter([string]$name,[string]$value){
        $this.Result += ".PARAMETER $name`n`t$value`n";
    }
    [void] AddAllParameter($names, $values){
        if($names.Length -ne $values.Length){
            throw "Length was not equal: $names , $values"
        }
        for($i = 0; $i -lt $names.Length;$i++)
        {
            $this.AddParameter($names[$i],"Original Database Type: "+$values[$i]);
        }
    }
}