# Powershell script for loading SaS Graph data into Neo4j Master Node
#--------------------------------------------------------------------
# README - This powershell script will behave differently based on
# the version of powershell and the version of the operating system.
# This script was tested on powershell version 5 and windows 2012.



# import the Neo4j-Management module to load all Neo4j commandlets
Import-Module F:\Neo4j\bin\Neo4j-Management.psd1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Set the Neo4j home in the shell path
$path='F:\Neo4j'
# ensure the path exists before executing the script
if (Test-Path $path){
$env:NEO4J_HOME = 'F:\Neo4j'

# the Neo4j service module failed so we replaced
# the call with the Microsoft service control commandlet
$stopped = Stop-Service -Name "Neo4j-Server"
Write-Host $stopped


$started = Start-Service -Name "Neo4j-Server"
Write-Host $started

# pass the neo4j home to the initialize commandlet
# and invoke with specific parameter overrides
$path | Initialize-Neo4jServer -EnableRemoteShell -EnableHTTPS

# begin reload of SaS graph by deleting existing SaS graph data
#
   $delResult = Start-Neo4jShell -file "F:\DataSource\delete.cql" -wait
   if ($delResult -eq 0) { 
        Write-Host "Delete Succeeded"
		Write-Host "Pausing while cluster synchronizes"
		Start-Sleep -s 120
############################################################################
        Write-Host "Loading New Account Data"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadADAccounts.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "ADAccount Load Succeeded"
        } else { Write-Host "ADAccount Load Unsuccesseful" }
		Write-Host "Pausing while index builds"
		Start-Sleep -s 90
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadAccounts.cql" -Wait        
        if ($loadResult -eq 0) {
            Write-Host "Account Load Succeeded"
        } else { Write-Host "Account Load Unsuccesseful" }
		Write-Host "Pausing while index builds"
		Start-Sleep -s 90
############################################################################
        Write-Host "Loading New Group Data"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadGroups.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Group Load Succeeded"
        } else { Write-Host "Group Load Unsuccesseful" }
		Write-Host "Pausing while index builds"
		Start-Sleep -s 90
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadADGroups.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "ADGroup Load Succeeded"
        } else { Write-Host "ADGroup Load Unsuccesseful" }
		Write-Host "Pausing while index builds"
		Start-Sleep -s 60
###########################################################################
        Write-Host "Loading New Server Data"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadServers.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Server Load Succeeded"
        } else { Write-Host "Server Load Unsuccesseful" }
		Write-Host "Pausing while index builds"
		Start-Sleep -s 60
###########################################################################
        Write-Host "Loading New Silo Data"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadSilos.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Silo Load Succeeded"
        } else { Write-Host "Silo Load Unsuccesseful" }
		Write-Host "Pausing while index builds"
		Start-Sleep -s 60
###########################################################################
        Write-Host "Loading New ADAccount -> Group Relationships"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadADGroupAccountRels.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "ADAccount -> Group Relationship Load Succeeded"
        } else { Write-Host "ADAccount -> Group Relationship Load Unsuccesseful" }
###########################################################################
        Write-Host "Loading New Group -> Group Relationships"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadGroupGroupRels.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Group -> Group Relationship Load Succeeded"
        } else { Write-Host "Group -> Group Relationship Load Unsuccesseful" }
###########################################################################
        Write-Host "Loading New Group -> Silo Relationships"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadSiloGroupRels.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Silo -> Group Relationship Load Succeeded"
        } else { Write-Host "Silo -> Group Relationship Load Unsuccesseful" }
###########################################################################
        Write-Host "Loading New Account -> Silo Relationships"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadADAccountSiloRels.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Account -> Silo Relationship Load Succeeded"
        } else { Write-Host "Account -> Silo Relationship Load Unsuccesseful" }
###########################################################################
        Write-Host "Loading New Account -> Account Relationships"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadAccountAccountRels.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Account -> Account Relationship Load Succeeded"
        } else { Write-Host "Account -> Account Relationship Load Unsuccesseful" }
###########################################################################
        Write-Host "Loading New Group -> Server Relationships"
        $loadResult = Start-Neo4jShell -path -file "F:\DataSource\LoadGroupServerRels.cql" -Wait
        if ($loadResult -eq 0) {
            Write-Host "Group -> Server Relationship Load Succeeded"
        } else { Write-Host "Group -> Server Relationship Load Unsuccesseful" }
###########################################################################

         

    } else { Write-Host "Delete Unsuccessful, aborting script" }
   
   
}