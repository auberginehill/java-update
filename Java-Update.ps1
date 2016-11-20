<#
Java-Update.ps1

Please Note:
- It's assumed that a 64-bit Java is going to be used in a 64-bit machine.
- It's assumed that only one (the most recent non-beta available) version of Java is intended to be used.
- If enough rights are deemed to be possessed (PowerShell has been started with the 'run as an administrator' option), any not up-to-date versions of Java will be uninstalled, and successively if the most recent non-beta version of Java is not found on the system, one instance will be installed (the 64-bit Java to a 64-bit machine and the 32-bit Java to a 32-bit machine).
- So if, for example, 32-bit and 64-bit outdated Java is installed in a 64-bit machine, only the most recent 64-bit Java replaces those versions. For more granular uninstallation/installation procedures, please consider doing the uninstallation manually via the Control Panel or by using the Java Uninstall Tool (please see the Step 19 for futher details about the Java Uninstall Tool) and downloading the relevant files manually (for download URLs, please see the Step 16 below) or changing this script according to the prevailing preferences.
- System Files are altered, for instance, in Steps 4, 5, 19 and 24.
- Please consider reviewing at least the Steps 4 and 5, since eventually (after some update iterations) the written settings will also be used in the Java installations not initiated by this script.
- Processes may be stopped in Step 6 and will be stopped in Step 18 without any further notification to the end-user or without any question prompts presented beforehand.
#>


$path = $env:temp
$computer = $env:COMPUTERNAME
$ErrorActionPreference = "Stop"
$start_time = Get-Date
$empty_line = ""
$quote ='"'
$unquote ='"'
$obj_original_java = @()
$obj_duplicate_uninstall = @()
$obj_remaining_java = @()
$obj_java_enumeration = @()
$obj_old_java_uninstall = @()
$obj_java_new = @()


# C:\Windows\system32\msiexec.exe
$path_system_32 = [Environment]::GetFolderPath("System")
$msiexec = "$path_system_32\msiexec.exe"

# C:\Windows\system32\cmd.exe
$cmd = "$path_system_32\cmd.exe"

# Java Uninstall Tool URL:
$uninstaller_tool_url = "https://javadl-esd-secure.oracle.com/update/jut/JavaUninstallTool.exe"

# 32-bit Java ID Numbers (JRE 4 -)
# Source: http://pastebin.com/73JqpTqv
# Source: https://github.com/bmrf/standalone_scripts/blob/master/java_runtime_nuker.bat
# Source: http://www.itninja.com/question/silent-uninstall-java-all-versions
$regex_32_a = "{26A24AE4-039D-4CA4-87B4-2F32(\d+)..}"
$regex_32_b = "{26A24AE4-039D-4CA4-87B4-2F.32(\d+)..}"
$regex_32_c = "{3248F0A8-6813-11D6-A77B-00B0D0(\d+).}"
$regex_32_d = "{7148F0A8-6813-11D6-A77B-00B0D0(\d+).}"

# 64-bit Java ID Numbers (Java 6 Update 23 -)
# Source: http://pastebin.com/73JqpTqv
# Source: https://github.com/bmrf/standalone_scripts/blob/master/java_runtime_nuker.bat
# Source: http://www.itninja.com/question/silent-uninstall-java-all-versions
$regex_64_a = "{26A24AE4-039D-4CA4-87B4-2F64(\d+)..}"
$regex_64_b = "{26A24AE4-039D-4CA4-87B4-2F.64(\d+)..}"




# Step 1
# Determine the architecture of a machine                                                     # Credit: Tobias Weltner: "PowerTips Monthly vol 8 January 2014"
If ([IntPtr]::Size -eq 8) {
    $empty_line | Out-String
    "Running in a 64-bit subsystem" | Out-String
    $64 = $true
    $bit_number = "64"
    $registry_paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $empty_line | Out-String
} Else {
    $empty_line | Out-String
    "Running in a 32-bit subsystem" | Out-String
    $64 = $false
    $bit_number = "32"
    $registry_paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $empty_line | Out-String
} # else

# Determine if the script is run in an elevated window                                        # Credit: alejandro5042: "How to run exe with/without elevated privileges from PowerShell"
$is_elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")


# Function to check whether a program is installed or not
Function Check-InstalledSoftware ($display_name) {
    Return Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $display_name }
} # function


# Function to check whether a certain version of Java is installed or not
Function Check-JavaID ($id_number) {
    Return Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match $id_number }
} # function




# Step 2
# Find out the which kind of Java is installed
$java_is_installed = $false
$32_bit_java_is_installed = $false
$64_bit_java_is_installed = $false
$auto_updater_is_installed = $false

$existing_javas = Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Java*" -or $_.DisplayName -like "*J2SE Runtime*") -and ($_.Publisher -like "Oracle*" -or $_.Publisher -like "Sun*" )}
# $query= "select * from win32_Product where (Name like 'Java %' or Name like 'Java(TM)%' or Name like 'J2SE%') and (Name <> 'Java Auto Updater') and ((Vendor='Sun Microsystems, Inc.') or (Vendor='Oracle') or (Vendor='Oracle Corporation')) and (NOT Name like '%CompuGROUP%') and (NOT Name like '%IBM%') and (NOT Name like '%DB%') and (NOT Name like '%Advanced Imaging%') and (NOT Name like '%Media Framework%') and (NOT Name like '%SDK%') and (NOT Name like '%Development Kit%')"
# https://poshuninstalljava.codeplex.com/SourceControl/latest#uninstall-java.ps1


# Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Java*" -or $_.DisplayName -like "*J2SE Runtime*") -and ($_.Publisher -like "Oracle*" -or $_.Publisher -like "Sun*") -and (-not $_.DisplayName -like "*SDK*") -and (-not $_.DisplayName -like "*Development Kit*") }




# Number of Installed Javas
If ($existing_javas -eq $null) {
    $number_of_installed_javas = 0
} Else {
    $number_of_installed_javas = ($existing_javas | Measure-Object).Count
} # else


# Installed Java Types
If ($existing_javas -ne $null) {

    $java_is_installed = $true

    ForEach ($original_java in $existing_javas) {

        # Custom Uninstall Strings
        $original_arguments = "/uninstall $($original_java.PSChildName) /qn /norestart"
        $original_uninstall_string = "$msiexec /uninstall $($original_java.PSChildName) /qn"
        $original_powershell_uninstall_string = [string]"Start-Process -FilePath $msiexec -ArgumentList " + $quote + $original_arguments + $unquote + " -Wait"
        $original_product_version = ((Get-ItemProperty -Path "$($original_java.InstallLocation)\bin\java.exe" -ErrorAction SilentlyContinue -Name VersionInfo).VersionInfo).ProductVersion
        $regex_build = If ($original_product_version -ne $null) { $original_product_version -match "(?<P1>\d+)\.(?<P2>\d+)\.(?<P3>\d+)\.(?<P4>\d+)" } Else { $continue = $true }


                            $obj_original_java += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $original_java.DisplayName.replace("(TM)","")
                                'Version'                       = $original_java.DisplayVersion
                                'Major_Version'                 = [int32]$original_java.VersionMajor
                                'Build_Number'                  = If ($Matches.P4 -ne $null) { [string]"b" + $Matches.P4 } Else { $continue = $true }
                                'Install_Date'                  = $original_java.InstallDate
                                'Install_Location'              = $original_java.InstallLocation
                                'Publisher'                     = $original_java.Publisher
                                'Computer'                      = $computer
                                'ID'                            = $original_java.PSChildName
                                'Standard_Uninstall_String'     = $original_java.UninstallString
                                'Custom_Uninstall_String'       = $original_uninstall_string
                                'PowerShell_Uninstall_String'   = $original_powershell_uninstall_string
                                'Type'                          = If (($original_java.PSChildName -match $regex_32_a) -or ($original_java.PSChildName -match $regex_32_b) -or ($original_java.PSChildName -match $regex_32_c) -or ($original_java.PSChildName -match $regex_32_d)) {
                                                                            "32-bit"
                                                                        } ElseIf (($original_java.PSChildName -match $regex_64_a) -or ($original_java.PSChildName -match $regex_64_b)) {
                                                                            "64-bit"
                                                                        } Else {
                                                                            $continue = $true
                                                                        } # else
                                'Update_Number'                 = If (($original_java.PSChildName -match $regex_32_a) -or ($original_java.PSChildName -match $regex_32_b) -or ($original_java.PSChildName -match $regex_32_c) -or ($original_java.PSChildName -match $regex_32_d)) {
                                                                            [int32]$original_java.DisplayName.Split()[-1]
                                                                        } ElseIf (($original_java.PSChildName -match $regex_64_a) -or ($original_java.PSChildName -match $regex_64_b)) {
                                                                            [int32]$original_java.DisplayName.Split()[-2]
                                                                        } Else {
                                                                            $continue = $true
                                                                        } # else

                            } # New-Object
                        $obj_original_java.PSObject.TypeNames.Insert(0,"Original Installed Java Versions")

    } # foreach ($original_java)

} Else {
    $continue = $true
} # else


    # 32-bit Java
    If ((Check-JavaID $regex_32_a -ne $null) -or (Check-JavaID $regex_32_b -ne $null) -or (Check-JavaID $regex_32_c -ne $null) -or (Check-JavaID $regex_32_d -ne $null)) {

        $32_bit_java_is_installed = $true
        $original_java_32_bit_powershell_uninstall_string = $obj_original_java | Where-Object { $_.Type -eq "32-bit" } | Select-Object -ExpandProperty PowerShell_Uninstall_String

    } Else {
        $continue = $true
    } # else


    # 64-bit Java
    If ((Check-JavaID $regex_64_a -ne $null) -or (Check-JavaID $regex_64_b -ne $null)) {

        $64_bit_java_is_installed = $true
        $original_java_64_bit_powershell_uninstall_string = $obj_original_java | Where-Object { $_.Type -eq "64-bit" } | Select-Object -ExpandProperty PowerShell_Uninstall_String

    } Else {
        $continue = $true
    } # else


    # Installed Version(s)
    $installed_java_version_text_format = ($obj_original_java | Select-Object -ExpandProperty Name)

    # Installed Java Version Number(s)
    $installed_java_version = $obj_original_java | Where-Object { $_.Name -ne "Java Auto Updater" } | Select-Object -ExpandProperty Version

    # Installed Java Main Version(s)
    $installed_java_major_version = $obj_original_java | Where-Object { $_.Name -ne "Java Auto Updater" } | Select-Object -ExpandProperty Major_Version

    # Installed Java Update Number(s)
    $installed_java_update_number = $obj_original_java | Where-Object { $_.Name -ne "Java Auto Updater" } | Select-Object -ExpandProperty Update_Number

    # Installed Build Number(s)
    $installed_java_build_number = $obj_original_java | Where-Object { $_.Name -ne "Java Auto Updater" } | Select-Object -ExpandProperty Build_Number

    # Java Installation Path(s)
    $java_home_path = $obj_original_java | Where-Object { $_.Name -ne "Java Auto Updater" } | Select-Object -ExpandProperty Install_Location

    # Java Auto Updater Is Installed?
    If (Check-InstalledSoftware "Java Auto Updater") { $auto_updater_is_installed = $true } Else { $continue = $true }

            If (($auto_updater_is_installed -eq $true) -and ($number_of_installed_javas -eq 1)) {
                # Only the Java Auto Updater is installed
                $exception_one = $true
            } Else {
                $continue = $true
            } # else




# Step 3
# Gather more details about the latest installed version of Java
$java_reg_path = 'HKLM:\Software\JavaSoft\Java Runtime Environment'
If ((Test-Path $java_reg_path) -eq $true) {

    # $java_8_is_installed = $true
    $existing_installed_version = (Get-ItemProperty -Path $java_reg_path -Name CurrentVersion).CurrentVersion

    # Java Installation Path
    $java_home_path_reg = (Get-ItemProperty -Path "$java_reg_path\$existing_installed_version" -Name JavaHome).JavaHome

    # Installed Java Description:
    $installed_java_description = ((Get-ChildItem "$java_home_path_reg\bin\java.exe").VersionInfo.ProductName).Replace("(TM)","")

    # Installed Java Version (legacy_format):
    # 8.0.1110.14
    $installed_java_version_alternative_legacy_format = (Get-ChildItem "$java_home_path_reg\bin\java.exe").VersionInfo.ProductVersion

    # Latest installed Java Main Version:
    $latest_installed_java_major_version = [int32](Get-ChildItem "$java_home_path_reg\bin\java.exe").VersionInfo.ProductMajorPart

    # Installed Java Update Number (legacy_format):
    # 1110
    $installed_java_alternative_legacy_update_number = [int32](Get-ChildItem "$java_home_path_reg\bin\java.exe").VersionInfo.ProductBuildPart

} Else {
    $continue = $true
} # else (Step 3)




# Step 4
# Set the Java deployment properties and with an alternative method find out the build number
# Note: Please consider reviewing these settings, since eventually (after some update iterations) these will also be used in the Java installations not initiated by this script.
# Source: http://docs.oracle.com/javase/8/docs/technotes/guides/deploy/properties.html

<#

        The following locations provide examples for each operating system:

            Windows 7:
            For user jsmith running on Windows 7, the deployment.properties file would be located in the following directory:
            C:\Users\jsmith\AppData\LocalLow\Sun\Java\Deployment\deployment.properties
            <User Application Data Folder>\LocalLow\Sun\Java\Deployment\deployment.properties

            Linux:
            For user bjones running on Solaris or Linux, the deployment.properties file would be located in the following directory:
            /home/bjones/.java/deployment/deployment.properties
            ${user.home}/.java/deployment/deployment.properties

            OS X:
            For user jdoe running on OS X, the deployment.properties file would be located in the following directory:
            /Users/jdoe/Library/Application Support/Oracle/Java/Deployment/deployment.properties
            ~/Library/Application Support/Oracle/Java/Deployment/deployment.properties

#>

If ((Test-Path $java_reg_path) -eq $true) {

    # Step 4.1
    # "deployment.properties" File Location # 1/2 (Store user settings in the roaming profile = false)
    $appdata_path = [string][Environment]::GetFolderPath("LocalApplicationData") + 'Low\Sun\Java\Deployment'

        If ((Test-Path $appdata_path\deployment.properties) -eq $true) {
            $app_path = $appdata_path

                If ((Test-Path $appdata_path\deployment.properties_original) -eq $true) {
                    # If the "original" version of the deployment.properties file exists, do not overwrite it, but instead create another backup that gets overwritten each time this script is run this deep (practically if an update is attempted after the first update attempt, see below)
                    copy $appdata_path\deployment.properties $appdata_path\deployment.properties.old
                } Else {
                    # If an "original" version of this file does not exist, create it (practically when an update is attempted with this script for the first time)
                    copy $appdata_path\deployment.properties $appdata_path\deployment.properties_original
                } # else

        #  Get-Content $appdata_path\deployment.properties

            $seed_file = "$appdata_path\deployment.properties"
            $destination_file = "$appdata_path\deployment.properties.new"
            $new_configuration_file = New-Item -ItemType File -Path "$destination_file" -Force

            # Installed Java Version (Almost Full, with an underscore: x.y.z_nnn) - Legacy Format:
            # 1.8.0_101
            $installed_java_version_reg = ((Get-Content $seed_file | Select-String 'deployment.javaws.jre.0.product=') -split '=')[1]

            # Installed Java Version (x.y.z) - Old Name:
            $installed_baseline = $installed_java_version_reg.split("_")[0]

            # Installed Java Update Number (nnn):
            $installed_update_number_reg = [int32]$installed_java_version_reg.split("_")[1]


            # Security Tab
            # Disable Java content in the browser
            If ((Get-Content $seed_file | Select-String 'deployment.webjava.enabled') -eq $null) {
                # The 'display Java content in the browser' setting is missing = $true
                $new_configuration_file
                Add-Content $new_configuration_file -Value (Get-Content $seed_file)
                Add-Content $new_configuration_file -Value 'deployment.webjava.enabled=false'
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else

            If ((Get-Content $seed_file | Select-String 'deployment.webjava.enabled=true') -eq $true) {
                # Java content is enabled in the browser = $true
                (Get-Content $seed_file) | Foreach-Object { $_ -replace 'deployment.webjava.enabled=true', 'deployment.webjava.enabled=false' } | Set-Content $destination_file
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else


            # Advanced Tab
            # Disable Third Party Advertisements
            If ((Get-Content $seed_file | Select-String 'install.disable.sponsor.offers') -eq $null) {
                # The 'Third Party Advertisement' setting is missing = $true
                $new_configuration_file
                Add-Content $new_configuration_file -Value (Get-Content $seed_file)
                Add-Content $new_configuration_file -Value 'install.disable.sponsor.offers=true'
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else

            If ((Get-Content $seed_file | Select-String 'install.disable.sponsor.offers=false') -eq $true) {
                # The Third Party Advertisements are enabled = $true
                (Get-Content $seed_file) | Foreach-Object { $_ -replace 'install.disable.sponsor.offers=false', 'install.disable.sponsor.offers=true' } | Set-Content $destination_file
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else
        } # if (Step 4.1)


    # Step 4.2
    # "deployment.properties" File Location # 2/2 (Store user settings in the roaming profile = true)
    $alternative_appdata_path = [string][Environment]::GetFolderPath("ApplicationData") + '\Sun\Java\Deployment'

        If ((Test-Path $alternative_appdata_path\deployment.properties) -eq $true) {
            $app_path = $alternative_appdata_path

                If ((Test-Path $alternative_appdata_path\deployment.properties_original) -eq $true) {
                    # If the "original" version of the deployment.properties file exists, do not overwrite it, but instead create another backup that gets overwritten each time this script is run this deep (practically if an update is attempted after the first update attempt, see below)
                    copy $alternative_appdata_path\deployment.properties $alternative_appdata_path\deployment.properties.old
                } Else {
                    # If an "original" version of this file does not exist, create it (practically when an update is attempted with this script for the first time)
                    copy $alternative_appdata_path\deployment.properties $alternative_appdata_path\deployment.properties_original
                } # else

        #   Get-Content $alternative_appdata_path\deployment.properties

            $seed_file = "$alternative_appdata_path\deployment.properties"
            $destination_file = "$alternative_appdata_path\deployment.properties.new"
            $new_configuration_file = New-Item -ItemType File -Path "$destination_file" -Force

            # Installed Java Version (Almost Full, with an underscore: x.y.z_nnn) - Legacy Format:
            # 1.8.0_101
            $installed_java_version_reg = ((Get-Content $seed_file | Select-String 'deployment.javaws.jre.0.product=') -split '=')[1]

            # Installed Java Version (x.y.z) - Old Name:
            $installed_baseline = $installed_java_version_reg.split("_")[0]

            # Installed Java Update Number (nnn):
            $installed_update_number_reg = [int32]$installed_java_version_reg.split("_")[1]


            # Security Tab
            # Disable Java content in the browser
            If ((Get-Content $seed_file | Select-String 'deployment.webjava.enabled') -eq $null) {
                # The 'display Java content in the browser' setting is missing = $true
                $new_configuration_file
                Add-Content $new_configuration_file -Value (Get-Content $seed_file)
                Add-Content $new_configuration_file -Value 'deployment.webjava.enabled=false'
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else

            If ((Get-Content $seed_file | Select-String 'deployment.webjava.enabled=true') -eq $true) {
                # Java content is enabled in the browser = $true
                (Get-Content $seed_file) | Foreach-Object { $_ -replace 'deployment.webjava.enabled=true', 'deployment.webjava.enabled=false' } | Set-Content $destination_file
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else


            # Advanced Tab
            # Disable Third Party Advertisements
            If ((Get-Content $seed_file | Select-String 'install.disable.sponsor.offers') -eq $null) {
                # The 'Third Party Advertisement' setting is missing = $true
                $new_configuration_file
                Add-Content $new_configuration_file -Value (Get-Content $seed_file)
                Add-Content $new_configuration_file -Value 'install.disable.sponsor.offers=true'
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else

            If ((Get-Content $seed_file | Select-String 'install.disable.sponsor.offers=false') -eq $true) {
                # The Third Party Advertisements are enabled = $true
                (Get-Content $seed_file) | Foreach-Object { $_ -replace 'install.disable.sponsor.offers=false', 'install.disable.sponsor.offers=true' } | Set-Content $destination_file
                copy $destination_file $seed_file
            } Else {
                $continue = $true
            } # else
        } # if (Step 4.2)


    # Installed Java Build Name
    If ((Test-Path $java_reg_path\$installed_java_version_reg\MSI) -eq $true) {
        $installed_java_build_name_reg = (Get-ItemProperty -Path "$java_reg_path\$installed_java_version_reg\MSI" -Name FullVersion).FullVersion
    } Else {
    $continue = $true
    } # else

} Else {
    $continue = $true
} # else (Step 4)

            $obj_installed += New-Object -TypeName PSCustomObject -Property @{
                'Installed Version'                         = $installed_java_version_text_format
                'Installed Java Main Version'               = $installed_java_major_version
                'Installed Java Update Number'              = $installed_java_update_number
                'Installed Version (Legacy Name)'           = $installed_java_version
                'Installed Java Build'                      = $installed_java_build_number
                'Description'                               = $installed_java_description
                'Java Installation Path'                    = $java_home_path
                'Configuration File Location'               = $app_path
                'java_config.txt File Location'             = $path
                'Java Release History'                      = "https://www.java.com/en/download/faq/release_dates.xml"
                'Java Uninstallation Info'                  = "https://www.java.com/en/download/help/uninstall_java.xml"
                'Java Uninstall Tool URL'                   = $uninstaller_tool_url
                'Java Is Installed?'                        = $java_is_installed
                'How Many Instances of Java is Found?'      = $number_of_installed_javas
                'Java Auto Updater Is Installed?'           = $auto_updater_is_installed
                '32-bit Java Is Installed?'                 = $32_bit_java_is_installed
                '64-bit Java Is Installed?'                 = $64_bit_java_is_installed

            } # New-Object
        $obj_installed.PSObject.TypeNames.Insert(0,"Installed Java Versions")
        $obj_installed_selection = $obj_installed | Select-Object 'Installed Version','Installed Java Main Version','Installed Java Update Number','Installed Java Build','Installed Version (Legacy Name)','Description','Java Installation Path','Configuration File Location','java_config.txt File Location','Java Release History','Java Uninstallation Info','Java Uninstall Tool URL','Java Is Installed?','How Many Instances of Java is Found?','Java Auto Updater Is Installed?','32-bit Java Is Installed?','64-bit Java Is Installed?'


        # Display the Installed Java version numbers in console
        $empty_line | Out-String
        $header_installed = "Existing (Installed) Java Versions' Summary Table"
        $coline_installed = "-------------------------------------------------"
        Write-Output $header_installed
        $coline_installed | Out-String
        Write-Output $obj_installed_selection




# Step 5
# Create a Java Install Configuration File
# Note: Please see the steps 4.1 and 4.2 above for Java deployment properties (the "deployment.properties" -file)
# Note: Please consider reviewing these settings, since eventually (after some update iterations) these will also be used in the Java installations not initiated by this script.
# Source: http://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html#installing_with_config_file
# Source: http://docs.oracle.com/javase/8/docs/technotes/guides/install/windows_installer_options.html
# Source: http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_install_command_line
# Source: http://stackoverflow.com/questions/28043588/installing-jdk-8-and-jre-8-silently-on-a-windows-machine-through-command-line

<#
        jre [INSTALLCFG=configuration_file_path] [options]
        jre INSTALLCFG=configuration_file_path

                jre is the installer base file name, for example, jre-8u05-windows-i586.exe. jre refers to the JRE Windows Offline Installer base file name

                configuration_file_path is the path to the configuration file. Specifies the path of the installer configuration file.

                options are options with specified values separated by spaces. Use the same options as listed in Table 20-1, "Configuration File Options". In addition, you may use the option /s for the JRE Windows Offline Installer to perform a silent installation. You may substitute the value Enable for 1 and the value Disable for 0.

                        # Silent install removing old Java and creating a logfile example:
                        jre1.8.0_60.exe /s /L C:\pathsetup.log REMOVEOUTOFDATEJRES=1

                        # Using a configuration file and creating a logfile example:
                        jre-8u31-windows-x64.exe INSTALLCFG="%ProgramData%\Java8Configuration\Java8u31config.txt" /L C:\Temp\Java8u31x64itRuntime_install.log
                        jre-8-windows-i586.exe INSTALLCFG=jre-install-options.txt /s /L C:\TMP\jre-install.log

                        # cmd.exe Command Prompt with Administrative rights
                        msiexec.exe /i jre1.8.0_31_64bit.msi /L*v C:\Temp\Java8u31x64it_verb_Runtime_install.log INSTALL_SILENT="Enable" AUTO_UPDATE="Disable" WEB_JAVA="Enable" WEB_ANALYTICS="Disable" EULA="Disable" NOSTARTMENU="Enable" /qb
                        msiexec.exe /i %~dp0jre-8u45-windows-i586.msi INSTALLCFG=%~dp0custom.cfg /qn /L c:\log\jre-8u45-windows-i586.log

        # Basic UI mode:
        msiexec.exe /i installer.msi [INSTALLCFG=configuration_file_path] [options] /qb

        # Silent or unattended mode:
        msiexec.exe /i installer.msi [INSTALLCFG=configuration_file_path] [options] /qn
#>

    $java_config = New-Item -ItemType File -Path "$path\java_config.txt" -Force
    $java_config
    Add-Content $java_config -Value ('INSTALL_SILENT=1
AUTO_UPDATE=0
WEB_JAVA=0
WEB_JAVA_SECURITY_LEVEL=VH
WEB_ANALYTICS=0
EULA=0
REBOOT=0
REBOOT=Suppress
REBOOT=ReallySuppress
NOSTARTMENU=1
SPONSORS=0
REMOVEOUTOFDATEJRES=1')




# Step 6
# If more than one instance of Java is installed on the system, notify the user, and try to remove the excessive Java(s), if enough permissions are deemed to be available
If ((($number_of_installed_javas -eq 1) -and ($auto_updater_is_installed -eq $false)) -or (($number_of_installed_javas -eq 2) -and ($32_bit_java_is_installed -eq $true) -and ($64_bit_java_is_installed -eq $true) -and ($auto_updater_is_installed -eq $false))) {
    $excessive_javas_are_installed = $false
    $continue = $true

} ElseIf (($number_of_installed_javas -gt 1 ) -or ($auto_updater_is_installed -eq $true)) {
    $excessive_javas_are_installed = $true
    $empty_line | Out-String

        If ($number_of_installed_javas -gt 1) {
            Write-Warning "More than one instance of Java seems to be installed on the system."
        } ElseIf ($auto_updater_is_installed -eq $true) {
            Write-Warning "Java Auto Updater seems to be installed on the system."
        } Else {
            $continue = $true
        } # else

    # Check if the PowerShell session is elevated (has been run as an administrator) and try to remove the duplicate Java if enough permissions are deemed to be available
    If ($is_elevated -eq $true) {

            # Stop the Java-related processes
            Stop-Process -ProcessName '*messenger*' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'FlashPlayer*' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'plugin-container*' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'chrome*' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'opera*' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'firefox' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'palemoon' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'iexplore' -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName 'iexplorer' -ErrorAction SilentlyContinue -Force

            Stop-Process -ProcessName java -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName javaw -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName javaws -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName JP2Launcher -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName jqs -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName jucheck -ErrorAction SilentlyContinue -Force
            Stop-Process -ProcessName jusched -ErrorAction SilentlyContinue -Force

            Start-Sleep -s 2




            # The Duplicate Java Uninstallation Protocol
            # If ($installed_java_version_alternative_legacy_format -ne $null) {
            If ($obj_original_java -ne $null) {

                $timestamp_multi = Get-Date -Format HH:mm:ss
                $multi_text_1 = "$timestamp_multi - Initiating the Duplicate Java Uninstallation Protocol..."
                $multi_text_2 = "Trying to keep the latest installed version of Java (in both 32-bit and 64-bit flavors) and removing the earlier Java version (including the Java Auto Updater)."
                $multi_text_3 = "Trying to keep the latest installed version of Java (in both 32-bit and 64-bit flavors) and removing the earlier Java versions (including the Java Auto Updater)."
                $empty_line | Out-String
                Write-Output $multi_text_1
                $empty_line | Out-String
                If ($number_of_installed_javas -eq 2) {
                    Write-Output $multi_text_2
                } Else {
                    Write-Output $multi_text_3
                } # else




                # Uninstall the Java Auto Updater
                $the_java_auto_updater_exists = Check-InstalledSoftware "Java Auto Updater"

                    If ($the_java_auto_updater_exists) {

                            $argument_the_java_auto_updater = "/uninstall $($the_java_auto_updater_exists.PSChildName) /qn /norestart"
                            Start-Process -FilePath $msiexec -ArgumentList "$argument_the_java_auto_updater" -Wait
                            Start-Process -FilePath $msiexec -ArgumentList "/uninstall {4A03706F-666A-4037-7777-5F2748764D10} /qn /norestart" -Wait

                                If ((Check-InstalledSoftware "Java Auto Updater").DisplayName -eq $null) {
                                        $the_uninstall_text = "$($the_java_auto_updater_exists.DisplayName) is uninstalled."
                                        $empty_line | Out-String
                                        Write-Output $the_uninstall_text
                                } Else {
                                    $continue = $true
                                } # else If (Check-InstalledSoftware)

                    } Else {
                        $continue = $true
                    } # else If ($the_java_auto_updater_exists)




                # Find out the most recent Java out of all the installed Javas
                $highest_java_main_version = $obj_original_java | Select-Object -ExpandProperty Major_Version | Sort-Object -Descending | Select-Object -First 1
                $highest_java_update_number = $obj_original_java | Where-Object Major_Version -eq $highest_java_main_version | Select-Object -ExpandProperty Update_Number | Sort-Object -Descending | Select-Object -First 1
                $highest_java_version = $obj_original_java | Where-Object Major_Version -eq $highest_java_main_version | Where-Object Update_Number -eq $highest_java_update_number | Select-Object -ExpandProperty Version

                    ForEach ($java in $obj_original_java) {

                        If ($java.Version -ne $highest_java_version) {

                            # Uninstall any remaining duplicate and old instances of Java
                            # 8.0.1110.14
                            # Source: http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_system_requirements
                            <#
                                    Uninstalling the JRE with the Command Line

                                        32-bit JRE:         msiexec /x {26A24AE4-039D-4CA4-87B4-2F83218025F0}
                                        64-bit JRE:         msiexec /x {26A24AE4-039D-4CA4-87B4-2F86418025F0}

                                    The value in curly braces is the MSI product code for the JRE about to be uninstalled. The latter part, 18025, correlates to the JRE version 1.8.0_25.
                            #>
                            Start-Sleep -s 2
                            Write-Verbose "$($java.Name) version $($java.Version) installed on $($java.Install_Date) is uninstalling..."

                                        $obj_duplicate_uninstall += New-Object -TypeName PSCustomObject -Property @{
                                            'Computer'              = $computer
                                            'Name'                  = $java.Name
                                            'Version'               = $java.Version
                                            'IdentifyingNumber'     = $java.ID
                                            'InstallDate'           = $java.Install_Date
                                            'InstallLocation'       = $java.Install_Location
                                        } # New-Object
                                    $obj_duplicate_uninstall.PSObject.TypeNames.Insert(0,"Uninstalled Old Duplicate Java Versions")

                            $argument_java_uninstall = "/uninstall $($java.ID) /qn /norestart"
                            Start-Process -FilePath $msiexec -ArgumentList "$argument_java_uninstall" -Wait
                            $uninstall_text = "$($java.Name) is uninstalled."
                            $empty_line | Out-String
                            Write-Output $uninstall_text

                        } Else {

                            # This instance "slot" is altering the the latest installed Java version
                            # Do not touch the latest installed Java version = $true
                            $continue = $true

                        } # else
                    } # ForEach ($java)


                $timestamp_protocol = Get-Date -Format HH:mm:ss
                $protocol_text = "$timestamp_protocol - The Duplicate Java Uninstallation Protocol completed."
                $empty_line | Out-String
                Write-Output $protocol_text

            } Else {
                $continue = $true
            } # else (The Duplicate Java Uninstallation Protocol)




            # Check the Status of Java after The Duplicate Java Uninstallation Protocol
            $java_is_installed = $false
            $32_bit_java_is_installed = $false
            $64_bit_java_is_installed = $false
            $auto_updater_is_installed = $false

            $reduced_javas = Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Java*" -or $_.DisplayName -like "*J2SE Runtime*") -and ($_.Publisher -like "Oracle*" -or $_.Publisher -like "Sun*" )}

                    # Number of Installed Javas
                    If ($reduced_javas -eq $null) {
                        $number_of_installed_javas = 0
                    } Else {
                        $number_of_installed_javas = ($reduced_javas | Measure-Object).Count
                    } # else

                    # Is Java Installed?
                    If ($reduced_javas -ne $null) {
                        $java_is_installed = $true
                    } Else {
                        $continue = $true
                    } # else

                    # 32-bit Java
                    If ((Check-JavaID $regex_32_a -ne $null) -or (Check-JavaID $regex_32_b -ne $null) -or (Check-JavaID $regex_32_c -ne $null) -or (Check-JavaID $regex_32_d -ne $null)) {
                        $32_bit_java_is_installed = $true
                    } Else {
                        $continue = $true
                    } # else

                    # 64-bit Java
                    If ((Check-JavaID $regex_64_a -ne $null) -or (Check-JavaID $regex_64_b -ne $null)) {
                        $64_bit_java_is_installed = $true
                    } Else {
                        $continue = $true
                    } # else

                    # Java Auto Updater
                    If (Check-InstalledSoftware "Java Auto Updater") { $auto_updater_is_installed = $true } Else { $continue = $true }

    } Else {
        $continue = $true
    } # else (If "Administrator" -eq $true)
} Else {
    $continue = $true
} # else (Step 6)




# Step 7
# Enumerate the existing installed Javas
$registry_paths_selection = Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Java*" -or $_.DisplayName -like "*J2SE Runtime*") -and ($_.Publisher -like "Oracle*" -or $_.Publisher -like "Sun*" )}

If ($registry_paths_selection -ne $null) {

    ForEach ($item in $registry_paths_selection) {

        # Custom Uninstall Strings
        $arguments = "/uninstall $($item.PSChildName) /qn /norestart"
        $custom_uninstall_string = "$msiexec /uninstall $($item.PSChildName) /qn"
        $powershell_uninstall_string = [string]"Start-Process -FilePath $msiexec -ArgumentList " + $quote + $arguments + $unquote + " -Wait"
        $product_version_enum = ((Get-ItemProperty -Path "$($item.InstallLocation)\bin\java.exe" -ErrorAction SilentlyContinue -Name VersionInfo).VersionInfo).ProductVersion
        $regex_build_enumeration = If ($product_version_enum -ne $null) { $product_version_enum -match "(?<C1>\d+)\.(?<C2>\d+)\.(?<C3>\d+)\.(?<C4>\d+)" } Else { $continue = $true }


                            $obj_java_enumeration += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $item.DisplayName.replace("(TM)","")
                                'Version'                       = $item.DisplayVersion
                                'Main Version'                  = [int32]$item.VersionMajor
                                'Build'                         = If ($Matches.C4 -ne $null) { [string]"b" + $Matches.C4 } Else { $continue = $true }
                                'Install Date'                  = $item.InstallDate
                                'Install Location'              = $item.InstallLocation
                                'Publisher'                     = $item.Publisher
                                'Computer'                      = $computer
                                'Identifying Number'            = $item.PSChildName
                                'Standard Uninstall String'     = $item.UninstallString
                                'Custom Uninstall String'       = $custom_uninstall_string
                                'PowerShell Uninstall String'   = $powershell_uninstall_string
                                'Type'                          = If (($item.PSChildName -match $regex_32_a) -or ($item.PSChildName -match $regex_32_b) -or ($item.PSChildName -match $regex_32_c) -or ($item.PSChildName -match $regex_32_d)) {
                                                                            "32-bit"
                                                                        } ElseIf (($item.PSChildName -match $regex_64_a) -or ($item.PSChildName -match $regex_64_b)) {
                                                                            "64-bit"
                                                                        } Else {
                                                                            $continue = $true
                                                                        } # else
                                'Update Number'                 = If (($item.PSChildName -match $regex_32_a) -or ($item.PSChildName -match $regex_32_b) -or ($item.PSChildName -match $regex_32_c) -or ($item.PSChildName -match $regex_32_d)) {
                                                                            [int32]$item.DisplayName.Split()[-1]
                                                                        } ElseIf (($item.PSChildName -match $regex_64_a) -or ($item.PSChildName -match $regex_64_b)) {
                                                                            [int32]$item.DisplayName.Split()[-2]
                                                                        } Else {
                                                                            $continue = $true
                                                                        } # else

                            } # New-Object
                        $obj_java_enumeration.PSObject.TypeNames.Insert(0,"Java Version Enumeration")

    } # foreach ($item)


        # Display the Java Version Enumeration in console
        If ($obj_java_enumeration -ne $null) {
            $obj_java_enumeration_selection = $obj_java_enumeration | Select-Object 'Name','Main Version','Update Number','Build','Version','Install Date','Type','Install Location','Publisher','Computer','Identifying Number','PowerShell Uninstall String'
            $empty_line | Out-String
            $header_java_enumeration = "Enumeration of Java Versions Found on the System"
            $coline_java_enumeration = "------------------------------------------------"
            Write-Output $header_java_enumeration
            $coline_java_enumeration | Out-String
            Write-Output $obj_java_enumeration_selection
        } Else {
            $continue = $true
        } # else

} Else {
    $continue = $true
} # else (Step 7)



# Step 8
# Check if the computer is connected to the Internet                                          # Credit: ps1: "Test Internet connection"
If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $false) {
    $empty_line | Out-String
    Return "The Internet connection doesn't seem to be working. Exiting without checking the latest Java version numbers or without updating Java (at Step 8)."
} Else {
    Write-Verbose 'Checking the most recent Java version numbers from the Java/Oracle website...'
} # else




# Step 9
# Check the baseline Java version number by connecting to the Java/Oracle website (Page 1) and write it to  a file (The Baseline)
# Source: https://bugs.openjdk.java.net/browse/JDK-8005362
$baseline_url = "https://javadl-esd-secure.oracle.com/update/baseline.version"
$baseline_file = "$path\java_baseline.csv"

        try
        {
            $download_baseline = New-Object System.Net.WebClient
            $download_baseline.DownloadFile($baseline_url, $baseline_file)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $baseline_url"
            If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $true) {
                $page_exception_text = "Please consider running this script again. Sometimes this Oracle page just isn't queryable for no apparent reason. The success rate 'in the second go' usually seems to be a bit higher."
                $empty_line | Out-String
                Write-Output $page_exception_text
            } Else {
                $continue = $true
            } # else
            $empty_line | Out-String
            Return "Exiting without checking the latest Java version numbers or without updating Java (at Step 9)."
        }

Start-Sleep -Seconds 3

$source = Get-Content $baseline_file | Select-Object -First 1
$regex = $source -match "(?<P1>\d+).(?<P2>\d+).(?<P3>\d+)_(?<P4>\d+)"

# Most Recent Java Baseline Version (x.y.z) - Old Name:
$current_baseline = $source.split("_")[0]

# Most Recent Java Update Number (nnn):
# $current_update_number = $Matches.P4
$current_update_number = [int32]$source.split("_")[1]

# Most Recent Java Main Version (y):
$current_main_version = [int32]$Matches.P2

# Most Recent Java Version (Almost Full, with an underscore: x.y.z_nnn) - Legacy Format:
# 1.8.0_111
$current_version_full = Get-Content $baseline_file | Select-Object -First 1




# Step 10
# Check the most recent Java version numbers by connecting to the Java/Oracle website (Page 2, The Java Update Chart / Map)
# Source: http://superuser.com/questions/443686/silent-java-update-check
# http://javadl-esd.sun.com/update/1.8.0/map-m-1.8.0.xml
# http://javadl-esd.sun.com/update/1.8.0/map-1.8.0.xml
$update_map_url = "http://javadl-esd.sun.com/update/$current_baseline/map-m-$current_baseline.xml"

        try
        {
            $java_update_map = New-Object XML
            $java_update_map.Load($update_map_url)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $update_map_url"
            $empty_line | Out-String
            Return "Exiting without checking the latest Java version numbers or without updating Java (at Step 10)."
        }

# Update Chart:
$update_chart = $java_update_map.SelectNodes("/java-update-map/mapping")
$update_chart | Export-Csv $path\java_update_chart.csv -Delimiter ';' -NoTypeInformation -Encoding UTF8




# Step 11
# Check the Info on the most recent Java version Home Page (XML) by connecting to the Java/Oracle website (Page 3, The Home Page)
# https://javadl-esd-secure.oracle.com/update/1.8.0/au-descriptor-1.8.0_111-b14.xml
$most_recent_xml_home_page = ($java_update_map.SelectNodes("/java-update-map/mapping") | Select-Object -First 1).url

        try
        {
            $xml_info = New-Object XML
            $xml_info.Load($most_recent_xml_home_page)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $most_recent_xml_home_page"
            $empty_line | Out-String
            Return "Exiting without checking the latest Java version numbers or without updating Java (at Step 11)."
        }

# Further Info URL:
$further_info_url = $xml_info.SelectNodes("/java-update/information") | Select-Object -First 1 | Select-Object -ExpandProperty moreinfo

# Description:
$description = $xml_info.SelectNodes("/java-update/information") | Select-Object -First 1 | Select-Object -ExpandProperty descriptionfrom8

# Current Version (Full, with an underscore and a dash: x.y.z_nnn-abc):
# 1.8.0_111-b14
$current_version_build = ($xml_info.SelectNodes("/java-update/information") | Select-Object -First 1 | Select-Object -ExpandProperty version)[-1]

# Most Recent Java Version
$most_recent_java_version = [string]'Java ' + $current_main_version + ' Update ' + $current_update_number

# Most Recent Build
$current_build_number = $current_version_build.Split("-")[-1]

# Download URL:
# http://javadl.oracle.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/jre-8u111-windows-au.exe
$download_url = $xml_info.SelectNodes("/java-update/information") | Select-Object -First 1 | Select-Object -ExpandProperty url

# Custom Download URL:
# http://javadl.sun.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/xpiinstall.exe
$custom_download_url = "http://javadl.sun.com/webapps/download/GetFile/$current_version_build/windows-i586/xpiinstall.exe"

# Full 32-bit Download URL:
# http://javadl.sun.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/jre-8u111-windows-i586.exe
$full_32_download_url = "http://javadl.sun.com/webapps/download/GetFile/$current_version_build/windows-i586/jre-" + $current_main_version + "u" + $current_update_number + "-windows-i586.exe"

# Full 64-bit Download URL:
# http://javadl.sun.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/jre-8u111-windows-x64.exe
$full_64_download_url = "http://javadl.sun.com/webapps/download/GetFile/$current_version_build/windows-i586/jre-" + $current_main_version + "u" + $current_update_number + "-windows-x64.exe"


        $obj_most_recent += New-Object -TypeName PSCustomObject -Property @{
            'Most Recent Version'                       = $most_recent_java_version
            'Most Recent Java Main Version'             = [int32]$current_main_version
            'Most Recent Java Update Number'            = [int32]$current_update_number
            'Most Recent Build'                         = $current_build_number
            'Most Recent Build (Legacy Name, Full)'     = $current_version_build
            'Most Recent Version (Legacy Name)'         = $current_version_full
            'Description'                               = $description
            'Further Info'                              = $further_info_url
            'Java Uninstall Tool URL'                   = $uninstaller_tool_url
            'Download URL'                              = $download_url
            'Custom Download URL'                       = $custom_download_url
            'Full 32-bit Download URL'                  = $full_32_download_url
            'Full 64-bit Download URL'                  = $full_64_download_url
        } # New-Object
    $obj_most_recent.PSObject.TypeNames.Insert(0,"Most Recent non-beta Java Version Available")
    $obj_most_recent_selection = $obj_most_recent | Select-Object 'Most Recent Version','Most Recent Java Main Version','Most Recent Java Update Number','Most Recent Build','Most Recent Version (Legacy Name)','Description','Further Info','Java Uninstall Tool URL','Download URL','Custom Download URL','Full 32-bit Download URL','Full 64-bit Download URL'


    # Display the most recent Java version numbers in console
    $empty_line | Out-String
    $header_most_recent = "Most Recent non-beta Java Version Available"
    $coline_most_recent = "-------------------------------------------"
    Write-Output $header_most_recent
    $coline_most_recent | Out-String
    Write-Output $obj_most_recent_selection




# Step 12
# Try to determine which Java versions, if any, are outdated and need to be updated.
$downloading_java_is_required = $false
$downloading_java_32_is_required = $false
$downloading_java_64_is_required = $false

If ($java_is_installed -eq $true) {

    $most_recent_32_bit_java_already_exists = Check-InstalledSoftware "Java $current_main_version Update $current_update_number"
    $most_recent_64_bit_java_already_exists = Check-InstalledSoftware "Java $current_main_version Update $current_update_number (64-bit)"
    $java_auto_updater_exists = Check-InstalledSoftware "Java Auto Updater"
    $all_32_bit_javas = $obj_java_enumeration | Where-Object { $_.Type -eq "32-bit" }
    $number_of_32_bit_javas = ($all_32_bit_javas | Measure-Object).Count
    $all_64_bit_javas = $obj_java_enumeration | Where-Object { $_.Type -eq "64-bit" }
    $number_of_64_bit_javas = ($all_64_bit_javas | Measure-Object).Count

    # 32-bit
    If ($32_bit_java_is_installed -eq $false) {
        $continue = $true

    } ElseIf (($32_bit_java_is_installed -eq $true) -and ($most_recent_32_bit_java_already_exists) -and ($number_of_32_bit_javas -eq 1)) {

        # $downloading_java_32_is_required = $false
        $argument_32 = "/uninstall $($most_recent_32_bit_java_already_exists.PSChildName) /qn /norestart"
        $custom_32_uninstall_string = "$msiexec /uninstall $($most_recent_32_bit_java_already_exists.PSChildName) /qn"
        $powershell_32_uninstall_string = [string]"Start-Process -FilePath $msiexec -ArgumentList " + $quote + $argument_32 + $unquote + " -Wait"


                            $obj_32_installed_current += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $most_recent_32_bit_java_already_exists.DisplayName.replace("(TM)","")
                                'Version'                       = $most_recent_32_bit_java_already_exists.DisplayVersion
                                'Install_Date'                  = $most_recent_32_bit_java_already_exists.InstallDate
                                'Install_Location'              = $most_recent_32_bit_java_already_exists.InstallLocation
                                'Publisher'                     = $most_recent_32_bit_java_already_exists.Publisher
                                'Computer'                      = $computer
                                'Identifying_Number'            = $most_recent_32_bit_java_already_exists.PSChildName
                                'Standard_Uninstall_String'     = $most_recent_32_bit_java_already_exists.UninstallString
                                'Custom_Uninstall_String'       = $custom_32_uninstall_string
                                'PowerShell_Uninstall_String'   = $powershell_32_uninstall_string

                            } # New-Object
                        $obj_32_installed_current.PSObject.TypeNames.Insert(0,"Existing Current Java 32-bit")

        $empty_line | Out-String
        Write-Output "Currently (until the next Java version is released) the 32-bit $($obj_32_installed_current.Name) installed on $($obj_32_installed_current.Install_Date) doesn't need any further maintenance or care."

    } Else {
        $downloading_java_32_is_required = $true
        $downloading_java_is_required = $true

        ForEach ($32_bit_java in $all_32_bit_javas) {
            $install_date_32 = $32_bit_java | Select-Object -ExpandProperty "Install Date"

            If ($32_bit_java.Name -eq $most_recent_java_version) {
                $empty_line | Out-String
                Write-Output "Currently (until the next Java version is released) the 32-bit $($32_bit_java.Name) installed on $install_date_32 doesn't need any further maintenance or care."
            } Else {
                $empty_line | Out-String
                Write-Warning "$($32_bit_java.Name) seems to be outdated."
                $empty_line | Out-String
                Write-Output "The most recent non-beta Java version is $most_recent_java_version. The installed 32-bit Java version $($32_bit_java.Version) needs to be updated."
            } # else


        } # ForEach
    } # else


    # 64-bit
    If ($64_bit_java_is_installed -eq $false) {
        $continue = $true

    } ElseIf (($64_bit_java_is_installed -eq $true) -and ($most_recent_64_bit_java_already_exists) -and ($number_of_64_bit_javas -eq 1)) {

        # $downloading_java_64_is_required = $false
        $argument_64 = "/uninstall $($most_recent_64_bit_java_already_exists.PSChildName) /qn /norestart"
        $custom_64_uninstall_string = "$msiexec /uninstall $($most_recent_64_bit_java_already_exists.PSChildName) /qn"
        $powershell_64_uninstall_string = [string]"Start-Process -FilePath $msiexec -ArgumentList " + $quote + $argument_64 + $unquote + " -Wait"


                            $obj_64_installed_current += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $most_recent_64_bit_java_already_exists.DisplayName.replace("(TM)","")
                                'Version'                       = $most_recent_64_bit_java_already_exists.DisplayVersion
                                'Install_Date'                  = $most_recent_64_bit_java_already_exists.InstallDate
                                'Install_Location'              = $most_recent_64_bit_java_already_exists.InstallLocation
                                'Publisher'                     = $most_recent_64_bit_java_already_exists.Publisher
                                'Computer'                      = $computer
                                'Identifying_Number'            = $most_recent_64_bit_java_already_exists.PSChildName
                                'Standard_Uninstall_String'     = $most_recent_64_bit_java_already_exists.UninstallString
                                'Custom_Uninstall_String'       = $custom_64_uninstall_string
                                'PowerShell_Uninstall_String'   = $powershell_64_uninstall_string

                            } # New-Object
                        $obj_64_installed_current.PSObject.TypeNames.Insert(0,"Existing Current Java 64-bit")

        $empty_line | Out-String
        Write-Output "Currently (until the next Java version is released) the 64-bit $($obj_64_installed_current.Name) installed on $($obj_64_installed_current.Install_Date) doesn't need any further maintenance or care."

    } Else {
        $downloading_java_64_is_required = $true
        $downloading_java_is_required = $true

        ForEach ($64_bit_java in $all_64_bit_javas) {
            $install_date_64 = $64_bit_java | Select-Object -ExpandProperty "Install Date"

            If ($64_bit_java.Name -match $most_recent_java_version) {
                $empty_line | Out-String
                Write-Output "Currently (until the next Java version is released) the 64-bit $($64_bit_java.Name) installed on $install_date_64 doesn't need any further maintenance or care."
            } Else {
                $empty_line | Out-String
                Write-Warning "$($64_bit_java.Name) seems to be outdated."
                $empty_line | Out-String
                Write-Output "The most recent non-beta Java version is $most_recent_java_version. The installed 64-bit Java version $($64_bit_java.Version) needs to be updated."
            } # else

        } # ForEach
    } # else


    # Java Auto Updater
    If ($java_auto_updater_exists) {
        $argument_java_auto_updater = "/uninstall $($java_auto_updater_exists.PSChildName) /qn /norestart"
        $powershell_java_auto_updater_uninstall_string = [string]"Start-Process -FilePath $msiexec -ArgumentList " + $quote + $argument_java_auto_updater + $unquote + " -Wait"
        $empty_line | Out-String
        Write-Output "The Java Auto Updater seems to be installed on the system."
    } Else {
        $continue = $true
    } # else

} Else {
    $continue = $true
} # else




If ($java_is_installed -eq $true) {


                $obj_maintenance += New-Object -TypeName PSCustomObject -Property @{
                    'Open the java_config.txt file'             = [string]'Invoke-Item ' + $path + '\java_config.txt'
                    'Open the configuration file location'      = If ($app_path -ne $null) { [string]'Invoke-Item ' + $app_path } Else { [string]'-' }
                    'Uninstall the 32-bit Java'                 = If ($32_bit_java_is_installed -eq $true) { $original_java_32_bit_powershell_uninstall_string } Else { [string]'[not installed]' }
                    'Uninstall the 64-bit Java'                 = If ($64_bit_java_is_installed -eq $true) { $original_java_64_bit_powershell_uninstall_string } Else { [string]'[not installed]' }
                    'Uninstall the Java Auto Updater'           = If ($java_auto_updater_exists -ne $null) { $powershell_java_auto_updater_uninstall_string } Else { [string]'[not installed]' }
                } # New-Object
            $obj_maintenance.PSObject.TypeNames.Insert(0,"Maintenance")
            $obj_maintenance_selection = $obj_maintenance | Select-Object 'Open the java_config.txt file','Open the configuration file location','Uninstall the 32-bit Java','Uninstall the 64-bit Java','Uninstall the Java Auto Updater'


        # Display the Maintenance table in console
        $empty_line | Out-String
        $header_maintenance = "Maintenance"
        $coline_maintenance = "-----------"
        Write-Output $header_maintenance
        $coline_maintenance | Out-String
        Write-Output $obj_maintenance_selection




        $obj_downloading += New-Object -TypeName PSCustomObject -Property @{
            '32-bit Java'   = If ($32_bit_java_is_installed -eq $true) { $downloading_java_32_is_required } Else { [string]'-' }
            '64-bit Java'   = If ($64_bit_java_is_installed -eq $true) { $downloading_java_64_is_required } Else { [string]'-' }
        } # New-Object
    $obj_downloading.PSObject.TypeNames.Insert(0,"Maintenance Is Required for These Java Versions")
    $obj_downloading_selection = $obj_downloading | Select-Object '32-bit Java','64-bit Java'


    # Display in console which installers for Java need to be downloaded
    $empty_line | Out-String
    $header_downloading = "Maintenance Is Required for These Java Versions"
    $coline_downloading = "-----------------------------------------------"
    Write-Output $header_downloading
    $coline_downloading | Out-String
    Write-Output $obj_downloading_selection
    $empty_line | Out-String

} Else {
    $continue = $true
} # else




# Step 13
# Determine if there is a real need to carry on with the rest of the script.
If ($java_is_installed -eq $true) {
    If ($downloading_java_is_required -eq $false -and $auto_updater_is_installed -eq $false) {
        Return "The installed Java seems to be OK."
    } ElseIf  ($downloading_java_is_required -eq $false -and $auto_updater_is_installed -eq $true) {
        Return "The installed Java seems to be OK. The Java Auto Updater seems to be installed on the system, too."
    } Else {
        $continue = $true
    } # else
} ElseIf (Check-InstalledSoftware "Java Auto Updater" -ne $null) {
    $empty_line | Out-String
    Write-Warning "The Java Auto Updater seems to be the only Java installed on the system."
    $empty_line | Out-String
    Return "This script didn't detect that any 'real' Java would have been installed on the system. The Java Auto Updater, however, does seem to be installed."
} Else {
    Write-Warning "No Java seems to be installed on the system."
    $empty_line | Out-String
    $no_java_text_1 = "This script didn't detect that any Java would have been installed."
    $no_java_text_2 = "Please consider installing Java by visiting https://www.java.com/en/download/"
    $no_java_text_3 = "For full installation files please, for example, see the page"
    $no_java_text_4 = "https://www.java.com/en/download/manual.jsp or"
    $no_java_text_5 = "http://www.oracle.com/technetwork/java/javase/downloads/index.html"
    $no_java_text_6 = "and for the Java uninstaller tool, please visit"
    $no_java_text_7 = "https://www.java.com/en/download/faq/uninstaller_toolfaq.xml"
    Write-Output $no_java_text_1
    Write-Output $no_java_text_2
    Write-Output $no_java_text_3
    Write-Output $no_java_text_4
    Write-Output $no_java_text_5
    Write-Output $no_java_text_6
    Write-Output $no_java_text_7

    # Offer the option to install a specific version of Java, if no Java is detected and the script is run in an elevated window
    # Source: Microsoft TechNet: "Adding a Simple Menu to a Windows PowerShell Script": https://technet.microsoft.com/en-us/library/ff730939.aspx
    # Credit: lamaar75: "Creating a Menu": http://powershell.com/cs/forums/t/9685.aspx
    If ($is_elevated -eq $true) {
        $empty_line | Out-String
        Write-Verbose "Welcome to the Admin Corner." -verbose
        $title_1 = "Install Java"
        $message_1 = "Would you like to install the Java for Windows with this script?"

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription    "&Yes",    "Yes:     downloads a full offline Java installer (either 32- or 64-bit according to the system) and installs Java."
        $no = New-Object System.Management.Automation.Host.ChoiceDescription     "&No",     "No:      exits from this script (similar to Ctrl + C)."
        $exit = New-Object System.Management.Automation.Host.ChoiceDescription   "&Exit",   "Exit:    exits from this script (similar to Ctrl + C)."
        $abort = New-Object System.Management.Automation.Host.ChoiceDescription  "A&bort",  "Abort:   exits from this script (similar to Ctrl + C)."
        $cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "Cancel:  exits from this script (similar to Ctrl + C)."

        $options_1 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit, $abort, $cancel)
        $result_1 = $host.ui.PromptForChoice($title_1, $message_1, $options_1, 1)

            switch ($result_1)
                {
                    0 {
                    "Yes. Trying to download a full offline Java installer (either 32- or 64-bit according to the system) and install Java.";
                    $admin_corner = $true
                    $java_is_installed = $true
                    $installed_java_version_text_format = "[Nonexistent]"
                    $downloading_java_is_required = $true
                    $continue = $true
                    }
                    1 {
                    "No. Exiting from Java-Update script.";
                    Exit
                    }
                    2 {
                    "Exit. Exiting from Java-Update script.";
                    Exit
                    }
                    3 {
                    "Abort. Exiting from Java-Update script.";
                    Exit
                    }
                    4 {
                    "Cancel. Exiting from Java-Update script.";
                    Exit
                    } # 4
                } # switch

    } Else {
        Exit
    } # else (Admin Corner)
} # else (No Java)




# Step 14
# Check if the PowerShell session is elevated (has been run as an administrator)
If ($is_elevated -eq $false) {
    Write-Warning "It seems that this script is run in a 'normal' PowerShell window."
    $empty_line | Out-String
    Write-Verbose "Please consider running this script in an elevated (administrator-level) PowerShell window." -verbose
    $empty_line | Out-String
    $admin_text = "For performing system altering procedures, such as uninstalling Java or installing Java the elevated rights are mandatory. An elevated PowerShell session can, for example, be initiated by starting PowerShell with the 'run as an administrator' option."
    Write-Output $admin_text
    $empty_line | Out-String
    # Write-Verbose "Even though it could also be possible to write a self elevating PowerShell script (https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/) or run commands elevated in PowerShell (http://powershell.com/cs/blogs/tips/archive/2014/03/19/running-commands-elevated-in-powershell.aspx) with the UAC prompts, the new UAC pop-up window may come as a surprise to the end-user, who isn't neccesarily aware that this script needs the elevated rights to complete the intended actions."
    Return "Exiting without updating (at Step 14)."
} Else {
    $continue = $true
} # else




# Step 15
# Initiate the update process
$empty_line | Out-String
$timestamp = Get-Date -Format HH:mm:ss
$update_text = "$timestamp - Initiating the Java Update Protocol..."
Write-Output $update_text

# Determine the current directory                                                             # Credit: JaredPar and Matthew Pirocchi "What's the best way to determine the location of the current PowerShell script?"
$script_path = Split-Path -parent $MyInvocation.MyCommand.Definition

# "Manual" progress bar variables
$activity             = "Updating Java"
$status               = "Status"
$id                   = 1 # For using more than one progress bar
$total_steps          = 19 # Total number of the steps or tasks, which will increment the progress bar
$task_number          = 0.2 # An increasing numerical value, which is set at the beginning of each of the steps that increments the progress bar (and the value should be less or equal to total_steps). In essence, this is the "progress" of the progress bar.
$task                 = "Setting Initial Variables" # A description of the current operation, which is set at the beginning of each of the steps that increments the progress bar.

# Start the progress bar
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    # Specify [Esc] and [q] as the Cancel-key                                                 # Credit: Jeff: "Powershell show elapsed time"
    If ($Host.UI.RawUI.KeyAvailable -and ("q" -eq $Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character)) {
        Write-Host " ...Stopping the Java Update Protocol...";
        Break;
    } ElseIf ($Host.UI.RawUI.KeyAvailable -and (([char]27) -eq $Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character)) {
        Write-Host " ...Stopping the Java Update Protocol..."; Break;
    } Else {
        $continue = $true
    } # else




# Step 16
# Download the latest installation file for Java for Windows
# Source: http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_install_instructions
<#

                    # Download URL (clickable)
                    https://www.java.com/en/download/manual.jsp
                    http://www.oracle.com/technetwork/java/javase/downloads/index.html

                    # 32-bit Java for Windows
                    Windows x86 Offline (32-bit)
                    http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jre-8u111-windows-i586.exe
                    Please Note: In order to download products from Oracle Technology Network you must agree to the OTN license terms.
                    Full 32-bit Download URL: http://javadl.sun.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/jre-8u111-windows-i586.exe

                    # 64-bit Java for Windows
                    Windows x64 Offline (64-bit)
                    http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jre-8u111-windows-x64.exe
                    Please Note: In order to download products from Oracle Technology Network you must agree to the OTN license terms.
                    Full 64-bit Download URL: http://javadl.sun.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/jre-8u111-windows-x64.exe

#>
<#

                     The file name of the installer has one of the following formats:

                        32-bit systems: jre-[version]-windows-i586.msi
                        64-bit systems: jre-[version]-windows-x64.msi

                    Substitute the appropriate version number for [version] in a format such as [main_version]u[update_number]
                    For example, if you using the installer for update 1.8.0_40, the file name jre-[version]-windows-i586.msi would become jre-8u40-windows-i586.msi.

#>
<#

                    # Download Old Java

                    # 32-bit:
                        # http://download.oracle.com/otn/java/jdk/6u45-b06/jre-6u45-windows-i586.exe
                        # http://javadl.sun.com/webapps/download/GetFile/1.6.0_45-b06/windows-i586/jre-6u45-windows-i586-iftw.exe
                        # http://javadl.sun.com/webapps/download/GetFile/1.6.0_45-b06/windows-i586/jre-6u45-windows-i586.exe
                        # http://javadl.sun.com/webapps/download/GetFile/1.7.0_21-b11/windows-i586/jre-7u21-windows-i586.exe
                        # http://javadl.sun.com/webapps/download/GetFile/1.8.0_91-b15/windows-i586/jre-8u91-windows-i586.exe
                        # http://javadl.sun.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/jre-8u111-windows-i586.exe

                    # 64-bit:
                        # http://download.oracle.com/otn/java/jdk/7u80-b15/jre-7u80-windows-x64.exe
                        # http://javadl.sun.com/webapps/download/GetFile/1.8.0_91-b15/windows-i586/jre-8u91-windows-x64.exe
                        # http://javadl.sun.com/webapps/download/GetFile/1.8.0_111-b14/windows-i586/jre-8u111-windows-x64.exe


#>

If (($java_is_installed -eq $true) -and ($downloading_java_is_required -eq $true)) {

    $task_number = 2
    $task = "Downloading a full offline Java installer..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    If ($bit_number -eq "32") {
        $actual_download_url = $full_32_download_url
    } ElseIf ($bit_number -eq "64") {
        $actual_download_url = $full_64_download_url
    } Else {
        $continue = $true
    } # else

    $download_file = $actual_download_url.split("/")[-1]
    $java_save_location = "$path\$download_file"
    $java_is_downloaded = $false

    # Purge existing old Java installation files
    If ((Test-Path $java_save_location) -eq $true) {
        Write-Verbose "Deleting $java_save_location"
        Remove-Item -Path "$java_save_location"
    } Else {
        $continue = $true
    } # else

            try
            {
                $download_java = New-Object System.Net.WebClient
                $download_java.DownloadFile($actual_download_url, $java_save_location)
            }
            catch [System.Net.WebException]
            {
                Write-Warning "Failed to access $actual_download_url"
                $empty_line | Out-String
                Return "Exiting without installing a new Java version (at Step 16)."
            }

    Start-Sleep -s 2

    If ((Test-Path $java_save_location) -eq $true) {
        $java_is_downloaded = $true
    } Else {
        $java_is_downloaded = $false
    } # else

} Else {
    $continue = $true
} # else




# Step 17
# Download the Java Uninstaller Tool
$task_number = 5
$task = "Downloading the Java Uninstaller Tool from Oracle/Sun..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

$uninstaller_file = $uninstaller_tool_url.split("/")[-1]
$uninstaller_save_location = "$path\$uninstaller_file"
$uninstaller_is_downloaded = $false

# Purge existing old uninstaller files
If ((Test-Path $uninstaller_save_location) -eq $true) {
    Write-Verbose "Deleting $uninstaller_save_location"
    Remove-Item -Path "$uninstaller_save_location"
} Else {
    $continue = $true
} # else

        try
        {
            $download_uninstaller = New-Object System.Net.WebClient
            $download_uninstaller.DownloadFile($uninstaller_tool_url, $uninstaller_save_location)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $uninstaller_tool_url"
            $empty_line | Out-String
            Return "Exiting at Step 17 without updating Java."
        }

Start-Sleep -s 2

If ((Test-Path $uninstaller_save_location) -eq $true) {
    $uninstaller_is_downloaded = $true
} Else {
    $uninstaller_is_downloaded = $false
} # else




# Step 18
# Exit all browsers and other programs that use Java
<#
        If (Get-Process iexplore -ErrorAction SilentlyContinue) {
            $empty_line | Out-String
            Write-Warning "It seems that Internet Explorer is running."
            $empty_line | Out-String
            Return "Please close the Internet Explorer and run this script again. Exiting without updating..."
        } Else {
            $continue = $true
        } # else
#>
$task_number = 6
$task = "Stopping Java-related processes..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

Stop-Process -ProcessName '*messenger*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'FlashPlayer*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'plugin-container*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'chrome*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'opera*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'firefox' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'palemoon' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'iexplore' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'iexplorer' -ErrorAction SilentlyContinue -Force

Stop-Process -ProcessName Java -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName javaw -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName javaws -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName JP2Launcher -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName jqs -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName jucheck -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName jusched -ErrorAction SilentlyContinue -Force

If (($admin_corner -eq $true) -or ($java_home_path_reg -eq $null)) {
    $continue = $true
} Else {
    Get-WmiObject Win32_Process | Where-Object { $_.ExecutablePath -like "*$java_home_path_reg*" } | Select-Object @{ Label='Name'; Expression={ $_.Name.Split('.')[0] }} | Stop-Process -ErrorAction SilentlyContinue -Force
}

Start-Sleep -s 5




# Step 19
# Uninstall Java completely
# Note: It seems that Windows PowerShell has to be run in an elevated state (Run as an Administrator) for this script to actually be able to uninstall Java.
# Source: https://www.java.com/en/download/faq/uninstaller_toolfaq.xml
# Source: http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_system_requirements
# Java Uninstall Tool URL: https://javadl-esd-secure.oracle.com/update/jut/JavaUninstallTool.exe

        # Unistall Java with the Java Uninstall tool

        <#
                    Versions of Java detected will be presented to the user for removal.
                    The user can choose to remove all or select specific versions of Java to remove.
                    Detects and allows removal of Java versions 1.4.2 and higher.
                    Only Java versions installed using the Java installer are detected. If Java is bundled with any application that uses its own installer, that version of Java will not be offered for removal.
                    The tool does not remove installations of the Java Development Kit (JDK).
                    The tool must be run online. The tool requires an internet connection because it checks for the latest version of the tool.

        # cd $path
        # .\$uninstaller_file | Out-Null
        # cd $script_path

        # Start-Process -FilePath $uninstaller_save_location -ArgumentList /qn /norestart -Wait

        #>
        <#
                Uninstalling the JRE with the Command Line

                    32-bit JRE:         msiexec /x {26A24AE4-039D-4CA4-87B4-2F83218025F0}
                    64-bit JRE:         msiexec /x {26A24AE4-039D-4CA4-87B4-2F86418025F0}

                The value in curly braces is the MSI product code for the JRE about to be uninstalled. The latter part, 18025, correlates to the JRE version 1.8.0_25.
        #>

If (($java_is_installed -eq $true) -and ($downloading_java_is_required -eq $true) -and ($admin_corner -ne $true)) {

    $task_number = 7
    $task = "Uninstalling outdated Java..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

        # Win32_Product Class
        # $javases = Get-WmiObject -Class Win32_Product | Where-Object { ($_.Name -like "*Java*" -or $_.Name -like "*J2SE Runtime*") -and ($_.Vendor -like "Oracle*" -or $_.Vendor -like "Sun*" )}
        # ForEach ($old_java in $javases) {
        # $uninstall = $old_java.Uninstall()
        # } # foreach ($old_java)

        # Uninstall the "Java Auto Updater"
        $old_java_auto_updater_exists = Check-InstalledSoftware "Java Auto Updater"

            If ($old_java_auto_updater_exists) {

                                $obj_old_java_uninstall += New-Object -TypeName PSCustomObject -Property @{
                                    'Computer'              = $computer
                                #   'Computer'              = $old_java_auto_updater_exists.PSComputerName
                                #   'Computer'              = $old_java_auto_updater_exists.__SERVER
                                    'Name'                  = $old_java_auto_updater_exists.DisplayName.replace("(TM)","")
                                    'Version'               = $old_java_auto_updater_exists.DisplayVersion
                                    'IdentifyingNumber'     = $old_java_auto_updater_exists.PSChildName
                                    'ProgramId'             = '-'
                                    'MsiPackageCode'        = '-'
                                } # New-Object
                            $obj_old_java_uninstall.PSObject.TypeNames.Insert(0,"Uninstalled Old Java Versions")

                    $argument_old_java_auto_updater = "/uninstall $($old_java_auto_updater_exists.PSChildName) /qn /norestart"
                    Start-Process -FilePath $msiexec -ArgumentList "$argument_old_java_auto_updater" -Wait
                    Start-Process -FilePath $msiexec -ArgumentList "/uninstall {4A03706F-666A-4037-7777-5F2748764D10} /qn /norestart" -Wait

            } Else {
                $continue = $true
            } # else

        $javases = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { ($_.Name -like "*Java*" -or $_.Name -like "*J2SE Runtime*") -and ($_.Vendor -like "Oracle*" -or $_.Vendor -like "Sun*" )}

        If ($javases -ne $null) {

            ForEach ($old_java in $javases) {

                    # Uninstall all instances of Java, apart from the "Java Auto Updater"
                    $argument_old_java = "/uninstall $($old_java.MsiProductCode) /qn /norestart"

                                $obj_old_java_uninstall += New-Object -TypeName PSCustomObject -Property @{
                                    'Computer'              = $computer
                                #   'Computer'              = $old_java.PSComputerName
                                #   'Computer'              = $old_java.__SERVER
                                    'Name'                  = $old_java.Name.replace("(TM)","")
                                    'Version'               = $old_java.Version
                                    'IdentifyingNumber'     = $old_java.MsiProductCode
                                    'ProgramId'             = $old_java.ProgramId
                                    'MsiPackageCode'        = $old_java.MsiPackageCode
                                } # New-Object
                            $obj_old_java_uninstall.PSObject.TypeNames.Insert(0,"Uninstalled Old Java Versions")

                        try
                        {
                            $uninstall = Start-Process -FilePath $msiexec -ArgumentList "$argument_old_java" -Wait
                            $uninstall
                        }
                        catch [System.Exception]
                        {
                            $uninstall.ReturnValue
                        }

                    Start-Sleep -s 4

            } # foreach ($old_java)

<#
            # Delete Java Registry Keys
            # Remove-Item -Recurse 'HKLM:\SOFTWARE\JavaSoft\Java Update' -Force
            # Remove-Item -Recurse 'HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Update' -Force
            Remove-Item -Recurse 'HKLM:\SOFTWARE\JavaSoft' -Force
            Remove-Item -Recurse 'HKLM:\SOFTWARE\JreMetrics' -Force
            Remove-Item -Recurse 'HKLM:\SOFTWARE\Wow6432Node\JavaSoft' -Force
            Remove-Item -Recurse 'HKLM:\SOFTWARE\Wow6432Node\JreMetrics' -Force

            # Remove Java Directories
            Remove-Item -Recurse -Path "C:\Program Files\Java\jre6" -Force
            Remove-Item -Recurse -Path "C:\Program Files (x86)\Java\jre6" -Force
            Remove-Item -Recurse -Path "C:\Program Files\Java\jre7" -Force
            Remove-Item -Recurse -Path "C:\Program Files (x86)\Java\jre7" -Force
#>

            # Display the uninstalled Java versions in console
            $obj_old_java_uninstall_selection = $obj_old_java_uninstall | Select-Object 'Name','Version','Computer'
            $empty_line | Out-String
            $header_old_java_uninstall = "Uninstalled Old Java Versions"
            $coline_old_java_uninstall = "-----------------------------"
            Write-Output $header_old_java_uninstall
            $coline_old_java_uninstall | Out-String
            Write-Output $obj_old_java_uninstall_selection

        } Else {
            $continue = $true
        } # else [If ($javases)]

} Else {
    $continue = $true
} # else (Step 19)




# Step 20
# Install the downloaded Java with using the created Java Install Configuration File
# Note: Please see the Step 5 for generating the Java Install Configuration File (java_config.txt)
# Note: Please see the Steps 4.1 and 4.2 above for Java deployment properties (the "deployment.properties" -file)
# Source: http://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html#installing_with_config_file
# Source: http://docs.oracle.com/javase/8/docs/technotes/guides/install/windows_installer_options.html
# Source: http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_install_command_line
# Source: http://stackoverflow.com/questions/28043588/installing-jdk-8-and-jre-8-silently-on-a-windows-machine-through-command-line
# Source: https://java.com/en/download/help/silent_install.xml

<#
        jre [INSTALLCFG=configuration_file_path] [options]
        jre INSTALLCFG=configuration_file_path

                jre is the installer base file name, for example, jre-8u05-windows-i586.exe. jre refers to the JRE Windows Offline Installer base file name

                configuration_file_path is the path to the configuration file. Specifies the path of the installer configuration file.

                options are options with specified values separated by spaces. Use the same options as listed in Table 20-1, "Configuration File Options". In addition, you may use the option /s for the JRE Windows Offline Installer to perform a silent installation. You may substitute the value Enable for 1 and the value Disable for 0.

                        # Silent install removing old Java and creating a logfile example:
                        jre1.8.0_60.exe /s /L C:\pathsetup.log REMOVEOUTOFDATEJRES=1

                        # Using a configuration file and creating a logfile example:
                        jre-8u31-windows-x64.exe INSTALLCFG="%ProgramData%\Java8Configuration\Java8u31config.txt" /L C:\Temp\Java8u31x64itRuntime_install.log
                        jre-8-windows-i586.exe INSTALLCFG=jre-install-options.txt /s /L C:\TMP\jre-install.log

                        # cmd.exe Command Prompt with Administrative rights
                        msiexec.exe /i jre1.8.0_31_64bit.msi /L*v C:\Temp\Java8u31x64it_verb_Runtime_install.log INSTALL_SILENT="Enable" AUTO_UPDATE="Disable" WEB_JAVA="Enable" WEB_ANALYTICS="Disable" EULA="Disable" NOSTARTMENU="Enable" /qb
                        msiexec.exe /i %~dp0jre-8u45-windows-i586.msi INSTALLCFG=%~dp0custom.cfg /qn /L c:\log\jre-8u45-windows-i586.log

        # Basic UI mode:
        msiexec.exe /i installer.msi [INSTALLCFG=configuration_file_path] [options] /qb

        # Silent or unattended mode:
        msiexec.exe /i installer.msi [INSTALLCFG=configuration_file_path] [options] /qn
#>

If ($java_is_downloaded -eq $true) {

    $task_number = 12
    $task = "Installing Java..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

        $install_arguments = [string]"INSTALLCFG=" + "$path\java_config.txt" + " /L " + "$path\java_install.log"
        Start-Process -FilePath $java_save_location -ArgumentList "$install_arguments" -Wait

    Start-Sleep -s 7

} Else {
    $continue = $true
} # else




# Step 21
# Enumerate the Javas after the update
$registry_paths_after_the_update = Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Java*" -or $_.DisplayName -like "*J2SE Runtime*") -and ($_.Publisher -like "Oracle*" -or $_.Publisher -like "Sun*" )}

    ForEach ($new_java in $registry_paths_after_the_update) {

        # Custom Uninstall Strings
        $new_arguments = "/uninstall $($new_java.PSChildName) /qn /norestart"
        $new_uninstall_string = "$msiexec /uninstall $($new_java.PSChildName) /qn"
        $new_powershell_uninstall_string = [string]"Start-Process -FilePath $msiexec -ArgumentList " + $quote + $new_arguments + $unquote + " -Wait"


                            $obj_java_new += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $new_java.DisplayName.replace("(TM)","")
                                'Version'                       = $new_java.DisplayVersion
                                'Install Date'                  = $new_java.InstallDate
                                'Install Location'              = $new_java.InstallLocation
                                'Publisher'                     = $new_java.Publisher
                                'Computer'                      = $computer
                                'Identifying Number'            = $new_java.PSChildName
                                'Standard Uninstall String'     = $new_java.UninstallString
                                'Custom Uninstall String'       = $new_uninstall_string
                                'PowerShell Uninstall String'   = $new_powershell_uninstall_string

                            } # New-Object
                        $obj_java_new.PSObject.TypeNames.Insert(0,"New Java Versions")

    } # foreach ($item)


        # Display the Java Version Enumeration in console
        If ($obj_java_new -ne $null) {
            $obj_java_new_selection = $obj_java_new | Select-Object 'Name','Version','Install Date','Install Location','Publisher','Computer','Identifying Number','PowerShell Uninstall String'
            $empty_line | Out-String
            $header_new_java = "New Java Versions"
            $coline_new_java = "-----------------"
            Write-Output $header_new_java
            $coline_new_java | Out-String
            Write-Output $obj_java_new_selection

        } Else {
            $continue = $true
        } # else




# Step 22
# Delete the downloaded files and close the progress bar

<#
            Start-Sleep -s 7

            If ($uninstaller_is_downloaded -eq $true) {

                $task_number = 15
                $task = "Deleting the downloaded files..."
                Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

                Remove-Item -Path "$uninstaller_save_location"
            } Else {
                $continue = $true
            } # else

            If ($java_is_downloaded -eq $true) {

                $task_number = 16
                $task = "Deleting the downloaded files..."
                Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

                Remove-Item -Path "$java_save_location"
            } Else {
                $continue = $true
            } # else
#>

# Close the progress bar
$task_number = 19
$task = "Finished updating Java."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100) -Completed




# Step 23
# Uninstall Java Auto Updater (Post-Installation)

$new_java_auto_updater_exists = Check-InstalledSoftware "Java Auto Updater"

    If ($new_java_auto_updater_exists) {

            $argument_new_java_auto_updater = "/uninstall $($new_java_auto_updater_exists.PSChildName) /qn /norestart"
            Start-Process -FilePath $msiexec -ArgumentList "$argument_new_java_auto_updater" -Wait
            Start-Process -FilePath $msiexec -ArgumentList "/uninstall {4A03706F-666A-4037-7777-5F2748764D10} /qn /norestart" -Wait

                        If ((Check-InstalledSoftware "Java Auto Updater").DisplayName -eq $null) {
                            $new_uninstall_text = "$($new_java_auto_updater_exists.DisplayName) is uninstalled."
                            $empty_line | Out-String
                            Write-Output $new_uninstall_text
                        } Else {
                            $continue = $true
                        } # else If (Check-InstalledSoftware)

    } Else {
        $continue = $true
    } # else




# Step 24
# Delete plugins registered with Mozilla applications after installing Java
Remove-Item -Recurse HKLM:\SOFTWARE\MozillaPlugins\@java*
Remove-Item -Recurse HKLM:\SOFTWARE\Wow6432Node\MozillaPlugins\@java*




# Step 25
# Find out how long the script took to complete
$end_time = Get-Date
$runtime = ($end_time) - ($start_time)

    If ($runtime.Days -ge 2) {
        $runtime_result = [string]$runtime.Days + ' days ' + $runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Days -gt 0) {
        $runtime_result = [string]$runtime.Days + ' day ' + $runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Hours -gt 0) {
        $runtime_result = [string]$runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Minutes -gt 0) {
        $runtime_result = [string]$runtime.Minutes + ' min ' + $runtime.Seconds + ' sec'
    } ElseIf ($runtime.Seconds -gt 0) {
        $runtime_result = [string]$runtime.Seconds + ' sec'
    } ElseIf ($runtime.Milliseconds -gt 1) {
        $runtime_result = [string]$runtime.Milliseconds + ' milliseconds'
    } ElseIf ($runtime.Milliseconds -eq 1) {
        $runtime_result = [string]$runtime.Milliseconds + ' millisecond'
    } ElseIf (($runtime.Milliseconds -gt 0) -and ($runtime.Milliseconds -lt 1)) {
        $runtime_result = [string]$runtime.Milliseconds + ' milliseconds'
    } Else {
        $runtime_result = [string]''
    } # else (if)

        If ($runtime_result.Contains(" 0 h")) {
            $runtime_result = $runtime_result.Replace(" 0 h"," ")
            } If ($runtime_result.Contains(" 0 min")) {
                $runtime_result = $runtime_result.Replace(" 0 min"," ")
                } If ($runtime_result.Contains(" 0 sec")) {
                $runtime_result = $runtime_result.Replace(" 0 sec"," ")
        } # if ($runtime_result: first)

# Display the runtime in console
$empty_line | Out-String
$timestamp_end = Get-Date -Format HH:mm:ss
$end_text = "$timestamp_end - Java Update Protocol completed."
Write-Output $end_text
$empty_line | Out-String
$runtime_text = "The update took $runtime_result."
Write-Output $runtime_text
$empty_line | Out-String




# [End of Line]


<#

   _____
  / ____|
 | (___   ___  _   _ _ __ ___ ___
  \___ \ / _ \| | | | '__/ __/ _ \
  ____) | (_) | |_| | | | (_|  __/
 |_____/ \___/ \__,_|_|  \___\___|


http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx                                # ps1: "Test Internet connection"
http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014             # Tobias Weltner: "PowerTips Monthly vol 8 January 2014"
http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1    # alejandro5042: "How to run exe with/without elevated privileges from PowerShell"
http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1      # JaredPar and Matthew Pirocchi "What's the best way to determine the location of the current PowerShell script?"
https://technet.microsoft.com/en-us/library/ff730939.aspx                                                           # Microsoft TechNet: "Adding a Simple Menu to a Windows PowerShell Script"
http://powershell.com/cs/forums/t/9685.aspx                                                                         # lamaar75: "Creating a Menu"
http://stackoverflow.com/questions/10941756/powershell-show-elapsed-time                                            # Jeff: "Powershell show elapsed time"



  _    _      _
 | |  | |    | |
 | |__| | ___| |_ __
 |  __  |/ _ \ | '_ \
 | |  | |  __/ | |_) |
 |_|  |_|\___|_| .__/
               | |
               |_|

#>

<#

.SYNOPSIS
Retrieves the latest Java version numbers from the Interwebs, and looks for the
installed Java versions on the system. If any outdated Java versions are found,
tries to update the Java.

.DESCRIPTION
Java-Update downloads a list of the most recent Java version numbers against which
it compares the Java version numbers found on the system and displays, whether a
Java update is needed or not. The actual update process naturally needs elevated
rights, and if a working Internet connection is not found, Java-Update will exit
at Step 8. Java-Update detects the installed Java(s) by querying the Windows
registry for installed programs. The keys from
HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ and
HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ are read on 64-bit
computers and on the 32-bit computers only the latter path is accessed.

Java-Update tries to write several Java-related configuration files at an early
stage, the "deployment.properties" -file in Step 4 and an Install Configuration
File in Step 5 (java_config.txt). In Step 6, if enough rights are granted (run
as an administrator) Java-Update tries to remove the excessive duplicate Java
versions, so that only those Java versions, which are deemed to be the latest,
will remain. Usually only one instance of Java will remain, but if the both
32-bit and 64-bit Javas have the same latest version number, both versions of Java
(32-bit and 64-bit) will be preserved. At this stage the Java Auto Updater will
also be uninstalled. In Step 6 the msiexec.exe is called to uninstall old Java(s),
so the process runs at a normal pace.

If Java-Update is run without elevated rights (but with a working Internet
connection) in a machine with old Java versions, it will be shown that a Java
update is needed, but Java-Update will exit at Step 13 before actually
downloading any files. To perform an update with Java-Update, PowerShell has to
be run in an elevated window (run as an administrator).

If Java-Update is run in an elevated PowerShell window and no Java is detected,
the script offers the option to install Java in the "Admin Corner", where, in
contrary to the main autonomous nature of Java-Update, an end-user input
is required.

If Java-Update is run with elevated rights (with a working Internet connection)
in a machine with old Java versions, Java-Update tries first to remove the
excessive duplicate Java versions (in Step 6) and in the update procedure
(if the most recent non-beta Java version is not detected and Java-Update is run
with administrative rights) Java-Update downloads the Java uninstaller from
Oracle/Sun (a file which is not used with this script) and a full Java offline
installer from Sun (the 64-bit Java for a 64-bit machine and the 32-bit Java for
a 32-bit machine). After stopping several Java-related processes Java-Update
uninstalls the outdated Java version(s) in two phases (Java Auto Updater first
and then the other Javas as listed by
Get-WmiObject -Class Win32_InstalledWin32Program command) with the
msiexec.exe /uninstall command and installs the downloaded Java version.

.OUTPUTS
Displays Java related information in console. Tries to remove excessive (duplicate)
Java versions and update the one remaining instance of Java to the latest non-beta
version (the 64-bit Java for a 64-bit machine and the 32-bit Java for a 32-bit
machine), if old Java(s) is/are found, if Java-Update is run in an elevated
Powershell window and if a working Internet connection is detected.
In addition to that...

The Java Deployment Configuration File (deployment.properties) is altered with new parameters,
if it is found in one of its default Windows locations, and the following backups are made. To
see the actual values that are being written, please see the Step 4 above (altering the
duplicated values below won't affect the script in any meaningful way):


    Java Deployment Configuration File in Step 4 (deployment.properties):

        Windows path 1:   %USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties
        Windows path 2:   %USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties


    'Original' file, which is created when the script tries to update something for
    the first time:

        Windows path 1:   %USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties_original
        Windows path 2:   %USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties_original


    'Backup' file, which is created when the script tries to update something for
    the second time and which gets overwritten in each successive update cycle:

        Windows path 1:   %USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties.old
        Windows path 2:   %USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties.old


    An auxiliary 'New' file, which contains the newest settings:

        Windows path 1:   %USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties.new
        Windows path 2:   %USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties.new


    The %USER_HOME_DIRECTORY% location represents the Home directory of an user, such as
    C:\Users\<username> and may be displayed in PowerShell with the [Environment]::GetFolderPath("User") command.

    The "Store user settings in the roaming profile" Java setting in the Java Control Panel (Advanced Tab)
    determines, whether the Windows path 1 or 2 is used. The default option is Windows path 1 (i.e. "Store user
    settings in the roaming profile" = false) i.e. %USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\
    is used by default.


    deployment.webjava.enabled=false        Security Tab: Enable Java content in the browser
                                            Set to true to run applets or Java Web Start (JWS) applications.
                                            Set to false to block applets and JWS applications from running.
    install.disable.sponsor.offers=true     Advanced Tab: Suppress sponsor offers when installing or updating Java


For a comprehensive list of available settings in the deployment.properties file,
please see the "Deployment Configuration File and Properties" page at
http://docs.oracle.com/javase/8/docs/technotes/guides/deploy/properties.html


An Install Configuration File is created in Step 5. To see the actual values that
are being written, please see the Step 5 above (altering the duplicated values
below won't affect the script in any meaningful way)


    Install Configuration File in Step 5 (java_config.txt):

        Windows:          %TEMP%\java_config.txt


    The %TEMP% location represents the current Windows temporary file folder.
    Please see the Notes-section below, how to determine where the current Windows
    temporary file folder is located. In PowerShell the command $env:temp displays
    the temp-folder path.


    INSTALL_SILENT=1                Silent (non-interactive) installation
    AUTO_UPDATE=0                   Disables the auto update feature
    WEB_JAVA=0                      Disables Java in the browser.
                                    Configures the installation so that downloaded Java
                                    applications are not allowed to run in a web browser
                                    or by Java Web Start.
    WEB_JAVA_SECURITY_LEVEL=VH      Sets the security level to very high
    WEB_ANALYTICS=0                 Disallow the installer to send installation-related
                                    statistics to an Oracle server.
    EULA=0                          If a Java applet or Java Web Start application is
                                    launched, do not prompt the user to accept the end-user
                                    license agreement.
    REBOOT=0                        The installer will never prompt for restarting the
                                    computer after installing the JRE.
    REBOOT=Suppress
    REBOOT=ReallySuppress
    NOSTARTMENU=1                   Specify that the installer installs the JRE without
                                    setting up Java start-up items.
    SPONSORS=0                      Install Java without being presented with any third
                                    party sponsor offers.
    REMOVEOUTOFDATEJRES=1           Enables uninstallation of existing out of date JREs
                                    during JRE install. Using REMOVEOUTOFDATEJRES=1
                                    removes all out-of-date Java versions from the system.


For a comprehensive list of available settings in a Configuration File,
please see the "Installing With a Configuration File" page at
https://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html


After the installation the downloaded files (uninstaller and the install file) are
not purged from the $path directory.


Additionally two auxiliary csv-files are created at $path and during the actual
update procedure a log-file is also created to the same location.


    %TEMP%\java_update_chart.csv        Gathered from an online XML-file.
    %TEMP%\java_baseline.csv            Contains the most recent Java version numbers.
    %TEMP%\java_install.log             A log-file about the installation procedure.


    The %TEMP% location represents the current Windows temporary file folder.
    Please see the Notes-section below, how to determine where the current Windows
    temporary file folder is located. In PowerShell the command $env:temp displays
    the temp-folder path.


To open these file locations in a Resource Manager Window, for instance a command


    Invoke-Item [string][Environment]::GetFolderPath("LocalApplicationData") + 'Low\Sun\Java\Deployment'

            or

    Invoke-Item [string][Environment]::GetFolderPath("ApplicationData") + '\Sun\Java\Deployment'

            or

    Invoke-Item $env:temp


may be used at the PowerShell prompt window [PS>].

.NOTES
Requires a working Internet connection for downloading a list of the most recent
Java version numbers.

Also requires a working Internet connection for downloading a Java uninstaller
and a complete Java installer from Oracle/Sun (but this procedure is not initiated,
if the system is deemed up-to-date).

For performing any actual updates with Java-Update, it's mandatory to
run this script in an elevated PowerShell window (where PowerShell has been started
with the 'run as an administrator' option). The elevated rights are needed for
uninstalling Java(s) and installing Java.

Please also notice that during the actual update phase Java-Update closes a bunch
of processes without any further notice in Step 18 and may do so also in Step 6.
Please also note that Java-Update alters the system files at least in Steps 4, 5, 19
and 24, so that for instance, all successive Java installations (even the ones not
initiated by this Java-Update script) will be done "silently" i.e. without any
interactive pages or prompts.

Please note that when run in an elevated PowerShell window and old Java(s)
is/are detected, Java-Update will automatically try to uninstall them and download
files from the Internet without prompting the end-user beforehand or without asking
any confirmations (in Step 6 and from Step 16 onwards).

The notoriously slow and possibly harmful Get-WmiObject -Class Win32_Product command
is deliberately not used for listing the installed Javas or for performing
uninstallations despite the powerful Uninstall-method associated with this command,
since the Win32_Product Class has some unpleasant behaviors - namely it uses a
provider DLL that validates the consistency of every installed MSI package on the
computer (msiprov.dll with the mandatorily initiated resiliency check, in which the
installations are verified and possibly also repaired or repair-installed), which
is the main reason behind the slow performance of this command. All in all
Win32_product Class is not query optimized and in Java-Update a combination of
various registry queries, msiexec.exe and
Get-WmiObject -Class Win32_InstalledWin32Program is used instead.

Please note that the downloaded files are placed in a directory, which is specified
with the $path variable (at line 15). The $env:temp variable points
to the current temp folder. The default value of the $env:temp variable is
C:\Users\<username>\AppData\Local\Temp (i.e. each user account has their own
separate temp folder at path %USERPROFILE%\AppData\Local\Temp). To see the current
temp path, for instance a command

    [System.IO.Path]::GetTempPath()

may be used at the PowerShell prompt window [PS>]. To change the temp folder for instance
to C:\Temp, please, for example, follow the instructions at
http://www.eightforums.com/tutorials/23500-temporary-files-folder-change-location-windows.html

    Homepage:           https://github.com/auberginehill/java-update
    Short URL:          http://tinyurl.com/hh7krx3
    Version:            1.2

.EXAMPLE
./Java-Update
Run the script. Please notice to insert ./ or .\ before the script name.

.EXAMPLE
help ./Java-Update -Full
Display the help file.

.EXAMPLE
Set-ExecutionPolicy remotesigned
This command is altering the Windows PowerShell rights to enable script execution. Windows PowerShell
has to be run with elevated rights (run as an administrator) to actually be able to change the script
execution properties. The default value is "Set-ExecutionPolicy restricted".


    Parameters:

    Restricted      Does not load configuration files or run scripts. Restricted is the default
                    execution policy.

    AllSigned       Requires that all scripts and configuration files be signed by a trusted
                    publisher, including scripts that you write on the local computer.

    RemoteSigned    Requires that all scripts and configuration files downloaded from the Internet
                    be signed by a trusted publisher.

    Unrestricted    Loads all configuration files and runs all scripts. If you run an unsigned
                    script that was downloaded from the Internet, you are prompted for permission
                    before it runs.

    Bypass          Nothing is blocked and there are no warnings or prompts.

    Undefined       Removes the currently assigned execution policy from the current scope.
                    This parameter will not remove an execution policy that is set in a Group
                    Policy scope.


For more information,
type "help Set-ExecutionPolicy -Full" or visit https://technet.microsoft.com/en-us/library/hh849812.aspx.

.EXAMPLE
New-Item -ItemType File -Path C:\Temp\Java-Update.ps1
Creates an empty ps1-file to the C:\Temp directory. The New-Item cmdlet has an inherent -NoClobber mode
built into it, so that the procedure will halt, if overwriting (replacing the contents) of an existing
file is about to happen. Overwriting a file with the New-Item cmdlet requires using the Force.
For more information, please type "help New-Item -Full".

.LINK
http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx
http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014
http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1
http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1
https://technet.microsoft.com/en-us/library/ff730939.aspx
http://powershell.com/cs/forums/t/9685.aspx
http://stackoverflow.com/questions/10941756/powershell-show-elapsed-time
http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_install_command_line
http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_install_instructions
http://docs.oracle.com/javacomponents/msi-jre8/install-guide/installing_jre_msi.htm#msi_system_requirements
http://docs.oracle.com/javase/8/docs/technotes/guides/deploy/properties.html
http://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html#installing_with_config_file
http://docs.oracle.com/javase/8/docs/technotes/guides/install/windows_installer_options.html
http://pastebin.com/73JqpTqv
http://stackoverflow.com/questions/28043588/installing-jdk-8-and-jre-8-silently-on-a-windows-machine-through-command-line
http://superuser.com/questions/443686/silent-java-update-check
https://bugs.openjdk.java.net/browse/JDK-8005362
https://github.com/bmrf/standalone_scripts/blob/master/java_runtime_nuker.bat
https://www.java.com/en/download/faq/uninstaller_toolfaq.xml

#>
