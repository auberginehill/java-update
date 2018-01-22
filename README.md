<!-- Visual Studio Code: For a more comfortable reading experience, use the key combination Ctrl + Shift + V
     Visual Studio Code: To crop the tailing end space characters out, please use the key combination Ctrl + A Ctrl + K Ctrl + X (Formerly Ctrl + Shift + X)
     Visual Studio Code: To improve the formatting of HTML code, press Shift + Alt + F and the selected area will be reformatted in a html file.
     Visual Studio Code shortcuts: http://code.visualstudio.com/docs/customization/keybindings (or https://aka.ms/vscodekeybindings)
     Visual Studio Code shortcut PDF (Windows): https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf


       _                         _    _           _       _
      | |                       | |  | |         | |     | |
      | | __ ___   ____ _ ______| |  | |_ __   __| | __ _| |_ ___
  _   | |/ _` \ \ / / _` |______| |  | | '_ \ / _` |/ _` | __/ _ \
 | |__| | (_| |\ V / (_| |      | |__| | |_) | (_| | (_| | ||  __/
  \____/ \__,_| \_/ \__,_|       \____/| .__/ \__,_|\__,_|\__\___|
                                       | |
                                       |_|                                                   -->


## Java-Update.ps1

<table>
    <tr>
        <td style="padding:6px"><strong>OS:</strong></td>
        <td colspan="2" style="padding:6px">Windows</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Type:</strong></td>
        <td colspan="2" style="padding:6px">A Windows PowerShell script</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Language:</strong></td>
        <td colspan="2" style="padding:6px">Windows PowerShell</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Status:</strong></td>
        <td colspan="2" style="padding:6px"><strong>Partially obsolete</strong>, please see https://github.com/auberginehill/java-update/issues/1 for further details. Java-Update.ps1 doesn't seem to work with JRE Family Version 9 or later versions of Java. JRE Family Version 8 is deemed to be "the latest" by this script, which only seems to be factually true concerning the 32-bit Java versions.</td>
    </tr>     
    <tr>
        <td style="padding:6px"><strong>Description:</strong></td>
        <td colspan="2" style="padding:6px">
            <p>
                Java-Update downloads a list of the most recent Java version numbers against which it compares the Java version numbers found on the system and displays, whether a Java update is needed or not. The actual update process naturally needs elevated rights, and if a working Internet connection is not found, Java-Update will exit at Step 8. Java-Update detects the installed Javas by querying the Windows registry for installed programs. The keys from <code>HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\</code> and <code>HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\</code> are read on 64-bit computers, and on 32-bit computers only the latter path is accessed.</p>
            <p>
                Java-Update tries to write several Java-related configuration files at an early stage, the "<code>deployment.properties</code>" -file in Step 4 and an Install Configuration File in Step 5 (<code>java_config.txt</code>). In Step 6, if enough rights are granted (run as an administrator) Java-Update tries to remove the excessive duplicate Java versions, so that only those Java versions, which are deemed to be the latest, would remain. Usually only one instance of Java will remain, but if both the 32-bit and 64-bit Javas have the same latest version number, both of the Java versions (32-bit and 64-bit) will be preserved. At this stage the Java Auto Updater will also be uninstalled. In Step 6 the <code>msiexec.exe</code> is called to uninstall old Javas, so the process runs at a normal pace.</p>
            <p>
                If Java-Update is run without elevated rights (but with a working Internet connection) in a machine with old Java versions, it will be shown that a Java update is needed, but Java-Update will exit at Step 13 before actually downloading any files. To perform an update with Java-Update, PowerShell has to be run in an elevated window (run as an administrator).</p>
            <p>
                If Java-Update is run in an elevated PowerShell window and no Java is detected, the script offers the option to install Java in the "<strong>Admin Corner</strong>", where, in contrary to the main autonomous nature of Java-Update, an end-user input is required.</p>
            <p>
                If Java-Update is run with elevated rights (with a working Internet connection) in a machine with old Java versions, Java-Update tries first to remove the excessive duplicate Java versions (at Step 6), and in the update procedure (if the most recent non-beta Java version is not detected and Java-Update is run with administrative rights) Java-Update downloads the Java uninstaller from Oracle/Sun (a file which is not used with this script) and a full Java offline installer from Sun (the 64-bit Java for a 64-bit machine and the 32-bit Java for a 32-bit machine). After stopping several Java-related processes Java-Update uninstalls the outdated Java versions in two phases (Java Auto Updater first and then the other Javas as listed by <code>Get-WmiObject -Class Win32_InstalledWin32Program</code> command) with the <code>msiexec.exe /uninstall</code> command and installs the downloaded Java version.</p>
        </td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Homepage:</strong></td>
      <td colspan="2" style="padding:6px"><a href="https://github.com/auberginehill/java-update">https://github.com/auberginehill/java-update</a>
      <br />Short URL: <a href="http://tinyurl.com/hh7krx3">http://tinyurl.com/hh7krx3</a></td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Version:</strong></td>
      <td colspan="2" style="padding:6px">1.4</td>
   </tr>
    <tr>
        <td rowspan="8" style="padding:6px"><strong>Sources:</strong></td>
        <td style="padding:6px">Emojis:</td>
        <td style="padding:6px"><a href="https://github.com/auberginehill/emoji-table">Emoji Table</a></td>
    </tr>
    <tr>
        <td style="padding:6px">ps1:</td>
        <td style="padding:6px"><a href="http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">Test Internet connection</a> (or one of the <a href="https://web.archive.org/web/20110612212629/http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">Tobias Weltner:</td>
        <td style="padding:6px"><a href="http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014">PowerTips Monthly vol 8 January 2014</a> (or one of the <a href="https://web.archive.org/web/20150110213108/http://powershell.com/cs/media/p/30542.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">alejandro5042:</td>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1">How to run exe with/without elevated privileges from PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px">JaredPar and Matthew Pirocchi:</td>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1">What's the best way to determine the location of the current PowerShell script?</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Microsoft TechNet:</td>
        <td style="padding:6px"><a href="https://technet.microsoft.com/en-us/library/ff730939.aspx">Adding a Simple Menu to a Windows PowerShell Script</a></td>
    </tr>
    <tr>
        <td style="padding:6px">lamaar75:</td>
        <td style="padding:6px"><a href="http://powershell.com/cs/forums/t/9685.aspx">Creating a Menu</a> (or one of the <a href="https://web.archive.org/web/20150910111758/http://powershell.com/cs/forums/t/9685.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">Jeff:</td>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/10941756/powershell-show-elapsed-time">Powershell show elapsed time</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Downloads:</strong></td>
        <td colspan="2" style="padding:6px">For instance <a href="https://raw.githubusercontent.com/auberginehill/java-update/master/Java-Update.ps1">Java-Update.ps1</a>.
            Or <a href="https://github.com/auberginehill/java-update/archive/master.zip">everything as a .zip-file</a>.</td>
    </tr>
</table>




### Screenshot

<ol><ol><ol><ol><ol>
<img class="screenshot" title="screenshot" alt="screenshot" height="80%" width="80%" src="https://raw.githubusercontent.com/auberginehill/java-update/master/Java-Update.png">
</ol></ol></ol></ol></ol>




### Outputs

<table>
    <tr>
        <th>:arrow_right:</th>
        <td style="padding:6px">
            <ul>
                <li>Displays Java related information in console. Tries to remove excessive (duplicate) Java versions and update the one remaining instance of Java to the latest non-beta version (the 64-bit Java for a 64-bit machine and the 32-bit Java for a 32-bit machine), if old Java(s) is/are found, if Java-Update is run in an elevated Powershell window and if a working Internet connection is detected. In addition to that... </li>
            </ul>
        </td>
    </tr>
    <tr>
        <th></th>
        <td style="padding:6px">
            <ul>
                <p>
                    <li>The Java Deployment Configuration File (<code>deployment.properties</code>) is altered with new parameters, if it is found in one of its default Windows locations, and the following backups are made.</li>
                </p>
                <ol>
                    <p><strong>Java Deployment Configuration File</strong> in Step 4 (<code>deployment.properties</code>):</p>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Path Alternative</strong></td>
                                <td style="padding:6px"><strong>File</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 1:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 2:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties</code></td>
                            </tr>
                        </table>
                    </p>
                    <p><strong>"Original" file</strong>, which is created when the script is run for the first time:</p>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Path Alternative</strong></td>
                                <td style="padding:6px"><strong>File</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 1:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties_original</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 2:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties_original</code></td>
                            </tr>
                        </table>
                    </p>
                    <p><strong>"Backup" file</strong>, which is created when the script is run for the second time and which gets overwritten in each successive time the script is run:</p>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Path Alternative</strong></td>
                                <td style="padding:6px"><strong>File</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 1:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties.old</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 2:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties.old</code></td>
                            </tr>
                        </table>
                    </p>
                    <p>An auxiliary <strong>"New" file</strong>, which contains the newest settings:</p>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Path Alternative</strong></td>
                                <td style="padding:6px"><strong>File</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 1:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\deployment.properties.new</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows path 2:</td>
                                <td style="padding:6px"><code>%USER_HOME_DIRECTORY%\AppData\Roaming\Sun\Java\Deployment\deployment.properties.new</code></td>
                            </tr>
                        </table>
                    </p>
                    <p>The <code>%USER_HOME_DIRECTORY%</code> location represents the Home directory of an user, such as <code>C:\Users\&lt;username&gt;</code> and may be displayed in PowerShell with the <code>[Environment]::GetFolderPath("User")</code> command.</p>
                    <p>The "Store user settings in the roaming profile" Java setting in the Java Control Panel (Advanced Tab) determines, whether the Windows path 1 or 2 is used. The default option is Windows path 1 (i.e. "Store user settings in the roaming profile" = false) i.e. <code>%USER_HOME_DIRECTORY%\AppData\LocalLow\Sun\Java\Deployment\</code> is used by default.</p>
                </ol>
                <p>
                    <li>To see the actual values that are being written, please see the Step 4 in the <a href="https://raw.githubusercontent.com/auberginehill/java-update/master/Java-Update.ps1">script</a> itself, where the following values are added or forced (overwritten) upon the original settings:</li>
                </p>
                <ol>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Value</strong></td>
                                <td style="padding:6px"><strong>Description</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>deployment.webjava.enabled=false</code></td>
                                <td style="padding:6px">Security Tab: Enable Java content in the browser
                                <br />Set to true to run applets or Java Web Start (JWS) applications.
                                <br />Set to false to block applets and JWS applications from running.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>install.disable.sponsor.offers=true</code></td>
                                <td style="padding:6px">Advanced Tab: Suppress sponsor offers when installing or updating Java</td>
                            </tr>
                        </table>
                    </p>
                    <p>For a comprehensive list of available settings in the deployment.properties file, please see the "<a href="http://docs.oracle.com/javase/8/docs/technotes/guides/deploy/properties.html">Deployment Configuration File and Properties</a>" page.</p>
                </ol>
                <p>
                    <li>An Install Configuration File is created in Step 5.</li>
                </p>
                <ol>
                    <p><strong>Install Configuration File</strong> in Step 5 (<code>java_config.txt</code>):</p>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>OS</strong></td>
                                <td style="padding:6px"><strong>File</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px">Windows:</td>
                                <td style="padding:6px"><code>%TEMP%\java_config.txt</code></td>
                            </tr>
                        </table>
                    </p>
                    <p>The <code>%TEMP%</code> location represents the current Windows temporary file folder. In PowerShell, for instance the command <code>$env:temp</code> displays the temp-folder path.</p>
                </ol>
                <p>
                    <li>To see the actual values that are being written, please see the Step 5 in the <a href="https://raw.githubusercontent.com/auberginehill/java-update/master/Java-Update.ps1">script</a> itself, where the following values are written:</li>
                </p>
                <ol>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Value</strong></td>
                                <td style="padding:6px"><strong>Description</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>INSTALL_SILENT=1</code></td>
                                <td style="padding:6px">Silent (non-interactive) installation</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>AUTO_UPDATE=0</code></td>
                                <td style="padding:6px">Disables the auto update feature</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>WEB_JAVA=0</code></td>
                                <td style="padding:6px">Disables Java in the browser.
                                <br />Configures the installation so that downloaded Java applications are not allowed to run in a web browser or by Java Web Start.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>WEB_JAVA_SECURITY_LEVEL=VH</code></td>
                                <td style="padding:6px">Sets the security level to very high</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>WEB_ANALYTICS=0</code></td>
                                <td style="padding:6px">Disallow the installer to send installation-related statistics to an Oracle server.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>EULA=0</code></td>
                                <td style="padding:6px">If a Java applet or Java Web Start application is launched, do not prompt the user to accept the end-user license agreement.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>REBOOT=0</code></td>
                                <td style="padding:6px" rowspan="3">The installer will never prompt for restarting the computer after installing the JRE.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>REBOOT=Suppress</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>REBOOT=ReallySuppress</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>NOSTARTMENU=1</code></td>
                                <td style="padding:6px">Specify that the installer installs the JRE without setting up Java start-up items.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>SPONSORS=0</code></td>
                                <td style="padding:6px">Install Java without being presented with any third party sponsor offers.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>REMOVEOUTOFDATEJRES=1</code></td>
                                <td style="padding:6px">Enables uninstallation of existing out of date JREs during JRE install. Using <code>REMOVEOUTOFDATEJRES=1</code> removes all out-of-date Java versions from the system.</td>
                            </tr>
                        </table>
                    </p>
                    <p>For a comprehensive list of available settings in a Configuration File, please see the "<a href="https://docs.oracle.com/javase/8/docs/technotes/guides/install/config.html">Installing With a Configuration File</a>" page.</p>
                </ol>
                <p>
                    <li>After the installation the downloaded files (uninstaller and the install file) are not purged from the <code>$path</code> directory.</li>
                </p>
                <p>
                    <li>Additionally two auxiliary csv-files are created at <code>$path</code> and during the actual update procedure a log-file is also created to the same location.</li>
                </p>
                <ol>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>File</strong></td>
                                <td style="padding:6px"><strong>Description</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>%TEMP%\java_update_chart.csv</code></td>
                                <td style="padding:6px">Gathered from an online XML-file.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>%TEMP%\java_baseline.csv</code></td>
                                <td style="padding:6px">Contains the most recent Java version numbers.</td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>%TEMP%\java_install.log</code></td>
                                <td style="padding:6px">A log-file about the installation procedure.</td>
                            </tr>
                        </table>
                    </p>
                    <p>The <code>%TEMP%</code> location represents the current Windows temporary file folder. In PowerShell, for instance the command <code>$env:temp</code> displays the temp-folder path.</p>
                </ol>
                <p>
                    <li>To open these file locations in a Resource Manager Window, for instance a command
                        <br />
                        <br /><code>Invoke-Item ([string][Environment]::GetFolderPath("LocalApplicationData") + 'Low\Sun\Java\Deployment')</code>
                        <br />
                        <br />or
                        <br />
                        <br /><code>Invoke-Item ([string][Environment]::GetFolderPath("ApplicationData") + '\Sun\Java\Deployment')</code>
                        <br />
                        <br />or
                        <br />
                        <br /><code>Invoke-Item ("$env:temp")</code>
                        <br />
                        <br />may be used at the PowerShell prompt window <code>[PS&gt;]</code>.
                    </li>
                </p>
            </ul>
        </td>
    </tr>
</table>




### Notes

<table>
    <tr>
        <th>:warning:</th>
        <td style="padding:6px">
            <ul>
                <li>Requires a working Internet connection for downloading a list of the most recent Java version numbers.</li>
            </ul>
        </td>
    </tr>
    <tr>
        <th></th>
        <td style="padding:6px">
            <ul>
                <p>
                    <li>Also requires a working Internet connection for downloading a Java uninstaller and a complete Java installer from Oracle/Sun (but this procedure is not initiated, if the system is deemed up-to-date). The download location URLs of the full installation files seem not to follow any pre-determined format anymore. The download locations of full installation files for both 32-bit and 64-bit Java versions are determined at Step 10 and Step 11.</li>
                </p>
                <p>
                    <li>For performing any actual updates with Java-Update, it's mandatory to run this script in an elevated PowerShell window (where PowerShell has been started with the 'run as an administrator' option). The elevated rights are needed for uninstalling Java(s) and installing Java.</li>
                </p>
                <p>
                    <li>Please also notice that during the actual update phase Java-Update closes a bunch of processes without any further notice in Step 18 and may do so also in Step 6. Please also note that Java-Update alters the system files at least in Steps 4, 5, 19 and 24, so that for instance, all successive Java installations (even the ones not initiated by this Java-Update script) will be done "silently" i.e. without any interactive pages or prompts.</li>
                </p>
                <p>
                    <li>Please note that when run in an elevated PowerShell window and old Java(s) is/are detected, Java-Update will automatically try to uninstall them and download files from the Internet without prompting the end-user beforehand or without asking any confirmations (in Step 6 and from Step 16 onwards).</li>
                </p>
                <p>
                    <li>The notoriously slow and possibly harmful <code>Get-WmiObject -Class Win32_Product</code> command is deliberately not used for listing the installed Javas or for performing uninstallations despite the powerful Uninstall-method associated with this command, since the <code>Win32_Product</code> Class has some unpleasant behaviors – namely it uses a provider DLL that validates the consistency of every installed MSI package on the computer (<code>msiprov.dll</code> with the mandatorily initiated resiliency check, in which the installations are verified and possibly also repaired or repair-installed), which is the main reason behind <a href="https://sdmsoftware.com/group-policy-blog/wmi/why-win32_product-is-bad-news/">the</a> <a href="https://blogs.technet.microsoft.com/askds/2012/04/19/how-to-not-use-win32_product-in-group-policy-filtering/">slow</a> <a href="https://support.microsoft.com/en-us/kb/974524">performance</a> of this command. All in all <code>Win32_product</code> Class is not query optimized and in Java-Update a combination of various registry queries, <code>msiexec.exe</code> and <code>Get-WmiObject -Class Win32_InstalledWin32Program</code> is used instead.</li>
                </p>
                <p>
                    <li>Please note that the downloaded files are placed in a directory, which is specified with the <code>$path</code> variable (at line 15). The <code>$env:temp</code> variable points to the current temp folder. The default value of the <code>$env:temp</code> variable is <code>C:\Users\&lt;username&gt;\AppData\Local\Temp</code> (i.e. each user account has their own separate temp folder at path <code>%USERPROFILE%\AppData\Local\Temp</code>). To see the current temp path, for instance a command
                    <br />
                    <br /><code>[System.IO.Path]::GetTempPath()</code>
                    <br />
                    <br />may be used at the PowerShell prompt window <code>[PS&gt;]</code>. To change the temp folder for instance to <code>C:\Temp</code>, please, for example, follow the instructions at <a href="http://www.eightforums.com/tutorials/23500-temporary-files-folder-change-location-windows.html">Temporary Files Folder - Change Location in Windows</a>, which in essence are something along the lines:
                        <ol>
                           <li>Right click Computer icon and select Properties (or select Start → Control Panel → System. On Windows 10 this instance may also be found by right clicking Start and selecting Control Panel → System... or by pressing <code>[Win-key]</code> + X and selecting Control Panel → System). On the window with basic information about the computer...</li>
                           <li>Click on Advanced system settings on the left panel and select Advanced tab on the "System Properties" pop-up window.</li>
                           <li>Click on the button near the bottom labeled Environment Variables.</li>
                           <li>In the topmost section, which lists the User variables, both TMP and TEMP may be seen. Each different login account is assigned its own temporary locations. These values can be changed by double clicking a value or by highlighting a value and selecting Edit. The specified path will be used by Windows and many other programs for temporary files. It's advisable to set the same value (a directory path) for both TMP and TEMP.</li>
                           <li>Any running programs need to be restarted for the new values to take effect. In fact, probably Windows itself needs to be restarted for it to begin using the new values for its own temporary files.</li>
                        </ol>
                    </li>
                </p>
            </ul>
        </td>
    </tr>
</table>




### Examples

<table>
    <tr>
        <th>:book:</th>
        <td style="padding:6px">To open this code in Windows PowerShell, for instance:</td>
   </tr>
   <tr>
        <th></th>
        <td style="padding:6px">
            <ol>
                <p>
                    <li><code>./Java-Update</code><br />
                    Runs the script. Please notice to insert <code>./</code> or <code>.\</code> before the script name.</li>
                </p>
                <p>
                    <li><code>help ./Java-Update -Full</code><br />
                    Displays the help file.</li>
                </p>
                <p>
                    <li><p><code>Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine</code><br />
                    This command is altering the Windows PowerShell rights to enable script execution in the default (<code>LocalMachine</code>) scope, and defines the conditions under which Windows PowerShell loads configuration files and runs scripts in general. In Windows Vista and later versions of Windows, for running commands that change the execution policy of the <code>LocalMachine</code> scope, Windows PowerShell has to be run with elevated rights (<dfn>Run as Administrator</dfn>). The default policy of the default (<code>LocalMachine</code>) scope is "<code>Restricted</code>", and a command "<code>Set-ExecutionPolicy Restricted</code>" will "<dfn>undo</dfn>" the changes made with the original example above (had the policy not been changed before...). Execution policies for the local computer (<code>LocalMachine</code>) and for the current user (<code>CurrentUser</code>) are stored in the registry (at for instance the <code>HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ExecutionPolicy</code> key), and remain effective until they are changed again. The execution policy for a particular session (<code>Process</code>) is stored only in memory, and is discarded when the session is closed.</p>
                        <p>Parameters:
                            <ul>
                                <table>
                                    <tr>
                                        <td style="padding:6px"><code>Restricted</code></td>
                                        <td colspan="2" style="padding:6px">Does not load configuration files or run scripts, but permits individual commands. <code>Restricted</code> is the default execution policy.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>AllSigned</code></td>
                                        <td colspan="2" style="padding:6px">Scripts can run. Requires that all scripts and configuration files be signed by a trusted publisher, including the scripts that have been written on the local computer. Risks running signed, but malicious, scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>RemoteSigned</code></td>
                                        <td colspan="2" style="padding:6px">Requires a digital signature from a trusted publisher on scripts and configuration files that are downloaded from the Internet (including e-mail and instant messaging programs). Does not require digital signatures on scripts that have been written on the local computer. Permits running unsigned scripts that are downloaded from the Internet, if the scripts are unblocked by using the <code>Unblock-File</code> cmdlet. Risks running unsigned scripts from sources other than the Internet and signed, but malicious, scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>Unrestricted</code></td>
                                        <td colspan="2" style="padding:6px">Loads all configuration files and runs all scripts. Warns the user before running scripts and configuration files that are downloaded from the Internet. Not only risks, but actually permits, eventually, running any unsigned scripts from any source. Risks running malicious scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>Bypass</code></td>
                                        <td colspan="2" style="padding:6px">Nothing is blocked and there are no warnings or prompts. Not only risks, but actually permits running any unsigned scripts from any source. Risks running malicious scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>Undefined</code></td>
                                        <td colspan="2" style="padding:6px">Removes the currently assigned execution policy from the current scope. If the execution policy in all scopes is set to <code>Undefined</code>, the effective execution policy is <code>Restricted</code>, which is the default execution policy. This parameter will not alter or remove the ("<dfn>master</dfn>") execution policy that is set with a Group Policy setting.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px; border-top-width:1px; border-top-style:solid;"><span style="font-size: 95%">Notes:</span></td>
                                        <td colspan="2" style="padding:6px">
                                            <ul>
                                                <li><span style="font-size: 95%">Please note that the Group Policy setting "<code>Turn on Script Execution</code>" overrides the execution policies set in Windows PowerShell in all scopes. To find this ("<dfn>master</dfn>") setting, please, for example, open the Local Group Policy Editor (<code>gpedit.msc</code>) and navigate to Computer Configuration → Administrative Templates → Windows Components → Windows PowerShell.</span></li>
                                            </ul>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th></th>
                                        <td colspan="2" style="padding:6px">
                                            <ul>
                                                <li><span style="font-size: 95%">The Local Group Policy Editor (<code>gpedit.msc</code>) is not available in any Home or Starter edition of Windows.</span></li>
                                                <ol>
                                                    <p>
                                                        <table>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><strong>Group Policy Setting</strong> "<code>Turn&nbsp;on&nbsp;Script&nbsp;Execution</code>"</td>
                                                                <td style="padding:6px; font-size: 85%"><strong>PowerShell Equivalent</strong> (concerning all scopes)</td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Not configured</code></td>
                                                                <td style="padding:6px; font-size: 85%">No effect, the default value of this setting</td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Disabled</code></td>
                                                                <td style="padding:6px; font-size: 85%"><code>Restricted</code></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Enabled</code> – Allow only signed scripts</td>
                                                                <td style="padding:6px; font-size: 85%"><code>AllSigned</code></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Enabled</code> – Allow local scripts and remote signed scripts</td>
                                                                <td style="padding:6px; font-size: 85%"><code>RemoteSigned</code></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Enabled</code> – Allow all scripts</td>
                                                                <td style="padding:6px; font-size: 85%"><code>Unrestricted</code></td>
                                                            </tr>
                                                        </table>
                                                    </p>
                                                </ol>
                                            </ul>
                                        </td>
                                    </tr>
                                </table>
                            </ul>
                        </p>
                    <p>For more information, please type "<code>Get-ExecutionPolicy -List</code>", "<code>help Set-ExecutionPolicy -Full</code>", "<code>help about_Execution_Policies</code>" or visit <a href="https://technet.microsoft.com/en-us/library/hh849812.aspx">Set-ExecutionPolicy</a> or <a href="http://go.microsoft.com/fwlink/?LinkID=135170">about_Execution_Policies</a>.</p>
                    </li>
                </p>
                <p>
                    <li><code>New-Item -ItemType File -Path C:\Temp\Java-Update.ps1</code><br />
                    Creates an empty ps1-file to the <code>C:\Temp</code> directory. The <code>New-Item</code> cmdlet has an inherent <code>-NoClobber</code> mode built into it, so that the procedure will halt, if overwriting (replacing the contents) of an existing file is about to happen. Overwriting a file with the <code>New-Item</code> cmdlet requires using the <code>Force</code>. If the path name and/or the filename includes space characters, please enclose the whole <code>-Path</code> parameter value in quotation marks (single or double):
                        <ol>
                            <br /><code>New-Item -ItemType File -Path "C:\Folder Name\Java-Update.ps1"</code>
                        </ol>
                    <br />For more information, please type "<code>help New-Item -Full</code>".</li>
                </p>
            </ol>
        </td>
    </tr>
</table>




### Contributing

<table>
    <tr>
        <th><img class="emoji" title="contributing" alt="contributing" height="28" width="28" align="absmiddle" src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f33f.png"></th>
        <td style="padding:6px"><strong>Bugs:</strong></td>
        <td style="padding:6px">Bugs can be reported by creating a new <a href="https://github.com/auberginehill/java-update/issues">issue</a>.</td>
    </tr>
    <tr>
        <th rowspan="2"></th>
        <td style="padding:6px"><strong>Feature Requests:</strong></td>
        <td style="padding:6px">Feature request can be submitted by creating a new <a href="https://github.com/auberginehill/java-update/issues">issue</a>.</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Editing Source Files:</strong></td>
        <td style="padding:6px">New features, fixes and other potential changes can be discussed in further detail by opening a <a href="https://github.com/auberginehill/java-update/pulls">pull request</a>.</td>
    </tr>
</table>




### www

<table>
    <tr>
        <th>:globe_with_meridians:</th>
        <td style="padding:6px"><a href="https://github.com/auberginehill/java-update">Script Homepage</a></td>
    </tr>
    <tr>
        <th rowspan="9"></th>
        <td style="padding:6px">ps1: <a href="http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">Test Internet connection</a> (or one of the <a href="https://web.archive.org/web/20110612212629/http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">Tobias Weltner: <a href="http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014">PowerTips Monthly vol 8 January 2014</a> (or one of the <a href="https://web.archive.org/web/20150110213108/http://powershell.com/cs/media/p/30542.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">alejandro5042: <a href="http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1">How to run exe with/without elevated privileges from PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px">JaredPar and Matthew Pirocchi: <a href="http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1">What's the best way to determine the location of the current PowerShell script?</a></td>
    </tr>
    <tr>
        <td style="padding:6px">lamaar75: <a href="http://powershell.com/cs/forums/t/9685.aspx">Creating a Menu</a> (or one of the <a href="https://web.archive.org/web/20150910111758/http://powershell.com/cs/forums/t/9685.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://www.credera.com/blog/technology-insights/perfect-progress-bars-for-powershell/">Perfect Progress Bars for PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://technet.microsoft.com/en-us/library/ff730939.aspx">Adding a Simple Menu to a Windows PowerShell Script</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/27175137/powershellv2-remove-last-x-characters-from-a-string#32608908">Powershellv2 - remove last x characters from a string</a></td>
    </tr>
    <tr>
        <td style="padding:6px">ASCII Art: <a href="http://www.figlet.org/">http://www.figlet.org/</a> and <a href="http://www.network-science.de/ascii/">ASCII Art Text Generator</a></td>
    </tr>
</table>




### Related scripts

 <table>
    <tr>
        <th><img class="emoji" title="www" alt="www" height="28" width="28" align="absmiddle" src="https://assets-cdn.github.com/images/icons/emoji/unicode/0023-20e3.png"></th>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/aa812bfa79fa19fbd880b97bdc22e2c1">Disable-Defrag</a></td>
    </tr>
    <tr>
        <th rowspan="26"></th>
        <td style="padding:6px"><a href="https://github.com/auberginehill/firefox-customization-files">Firefox Customization Files</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-ascii-table">Get-AsciiTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-battery-info">Get-BatteryInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-computer-info">Get-ComputerInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-culture-tables">Get-CultureTables</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-directory-size">Get-DirectorySize</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-hash-value">Get-HashValue</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-installed-programs">Get-InstalledPrograms</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-installed-windows-updates">Get-InstalledWindowsUpdates</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-powershell-aliases-table">Get-PowerShellAliasesTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/9c2f26146a0c9d3d1f30ef0395b6e6f5">Get-PowerShellSpecialFolders</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-ram-info">Get-RAMInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/eb07d0c781c09ea868123bf519374ee8">Get-TimeDifference</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-time-zone-table">Get-TimeZoneTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-unused-drive-letters">Get-UnusedDriveLetters</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-windows-10-lock-screen-wallpapers">Get-Windows10LockScreenWallpapers</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/emoji-table">Emoji Table</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/remove-duplicate-files">Remove-DuplicateFiles</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/remove-empty-folders">Remove-EmptyFolders</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/13bb9f56dc0882bf5e85a8f88ccd4610">Remove-EmptyFoldersLite</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/176774de38ebb3234b633c5fbc6f9e41">Rename-Files</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/rock-paper-scissors">Rock-Paper-Scissors</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/toss-a-coin">Toss-a-Coin</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/unzip-silently">Unzip-Silently</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/update-adobe-flash-player">Update-AdobeFlashPlayer</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/update-mozilla-firefox">Update-MozillaFirefox</a></td>
    </tr>
</table>
