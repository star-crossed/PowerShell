[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$OU,

    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

Set-Strictmode -Version 1

Import-Module ActiveDirectory # Need to have Windows RSAT installed or add the Windows Server feature for the module on the computer where this script runs

$group = Get-ADGroup "$GroupName"
Get-ADUser -SearchBase "$OU" -SearchScope "Subtree" -Filter "*" -Properties "*" | ForEach-Object {
    If ($(Get-ADUser -Filter "memberOf -RecursiveMatch '$($group.DistinguishedName)'" -SearchBase "$($_.DistinguishedName)") -eq $null) {
        If ($_.objectClass -eq "user") {
            $userObject = New-Object "System.Object"
            Add-Member -InputObject $userObject -Name "Name" -MemberType NoteProperty -Value $_.Name
            Add-Member -InputObject $userObject -Name "DistinguishedName" -MemberType NoteProperty -Value $_.DistinguishedName
            Export-Csv -Path ".\$GroupName-Missing.csv" -InputObject $userObject -NoTypeInformation -Append
        }
    }
}