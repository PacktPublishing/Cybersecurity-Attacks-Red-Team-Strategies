function Invoke-WindowsSearch
{
    param
    (
     [Parameter()][string] $SearchString = "password"
    )
    $query   = "select system.itemname, system.itempathdisplay from systemindex where contains('$SearchString')"
    $provider = "Provider=Search.CollatorDSO.1;Extended?PROPERTIES='Application=Windows'"
    $adapter  = new-object System.Data.OleDb.OleDBDataAdapter -Argument $query, $provider
    $results = new-object System.Data.DataSet

    $adapter.Fill($results)
    $results.Tables[0]
}


## Feel free to place this script in your profile, so it as available every time you launch a PowerShell sessions
## Or run Import-Module Invoke-WindowsSearch.psm1 to import it into your existing PowerShell session.