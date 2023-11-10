# Notepad Updater 
# Mike Harris
# Last updated 11-10-2023
# Creates backup of plugins folder, installs updated version and copies back over plugin folder. 

$PluginsPath = 'C:\Program Files\Notepad++\plugins'

#"Test to see if folder [$Folder]  exists"
if (Test-Path -Path $PluginsPath) {
        #Create new folder 
        $TempPluginHolder = 'C:\Notepad++Temp'
        New-Item -Path $TempPluginHolder -ItemType Directory

        #Copy contents of plugins folder 
        Copy-Item -Path $PluginsPath -Destination $TempPluginHolder -Recurse
} 
else {
    #DoNothing
}

#Install update to Notepad 
start-process -FilePath '.\npp.8.5.8.Installer.x64.exe' -ArgumentList '/S' -Verb runas -Wait

#Copy of copied folder moved back (Only if needed) 
Get-ChildItem $TempPluginHolder -Recurse | ForEach {
    $ModifiedDestination = $($_.FullName).Replace("$TempPluginHolder","$PluginsPath")
    If ((Test-Path $ModifiedDestination) -eq $False) {
        Copy-Item $_.FullName $ModifiedDestination -Recurse
        }
    }
	
#Delete created folder folder 
Remove-Item $TempPluginHolder -Recurse
