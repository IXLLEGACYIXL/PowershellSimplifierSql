class CodeBlockBuilder
{
    hidden $Query;
    hidden $Invocation;
    CodeBlockBuilder([string]$Invocation,[string]$Query){
        $this.Invocation = $Invocation;
        $this.Query = $Query;
    }
    [string] Get()
    {
        return [string]::Format($this.Invocation,$this.Query)
    }
}


