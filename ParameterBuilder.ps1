class ParameterBuilder
{
    $Tokens = @{
        Parameter = "`t[Mandatory=`${0}]`n`t[{1}] ${2}"
        Block = "[CmdletBinding()]`nparam`n({0}`n)`n"
    }
    [string] Get()
    {

    }
    [void]Add([string]$item,[string]$Mandatory ="false")
    {
        
    }
    [void]AddDbProvider([DatabaseProvider]$dbProvider){
        
    }
}
