# Name is Important
echo '
 .d8888b.          888b    888          .d8888b.          888       888         888b    888 
d88P  Y88b         8888b   888         d88P  Y88b         888       888         8888b   888 
Y88b.              88888b  888         888    888         888  d8b  888         88888b  888 
 "Y888b.           888Y88b 888         888                888 d888b 888         888Y88b 888 
    "Y88b.         888 Y88b888         888  88888         888d88888b888         888 Y88b888 
      "888         888  Y88888         888    888         88888P Y88888         888  Y88888 
Y88b  d88P         888   Y8888         Y88b  d88P         8888P   Y8888         888   Y8888 
 "Y8888P"          888    Y888          "Y8888P88         888P     Y888         888    Y888 
'

# Set Wget Progress to Silent, Becuase it slows down Downloading by +50x
echo "Setting Wget Progress to Silent, Becuase it slows down Downloading by +50x`n"
$ProgressPreference = 'SilentlyContinue'

# Check JDK-18 Availability or Download JDK-19
$jre8 = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Vendor -eq 'Oracle Corporation' -and $_.Caption -like 'Java 8 Update *' }

if (!$jre8) {
    echo "`n`t`tDownloading Java JRE ...."
    $downloadUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=246474_2dee051a5d0647d5be72a7c0abff270e"
    $outputFile = "jre-8.exe"

    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile

    echo "`n`t`tJRE-8 Downloaded, let's start the installation process"
    Start-Process -FilePath $outputFile -Wait -ArgumentList "/s"

    Remove-Item $outputFile
} else {
    echo "`n`nRequired JRE-8 is Installed`n"
    $jre8
}


# Check JRE-8 Availability or Download JRE-8
$jre8 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" |where Caption -clike "Java 8 Update *"
if (!($jre8)){
    echo "`n`t`tDownloading Java JRE ...."
    wget "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=246474_2dee051a5d0647d5be72a7c0abff270e" -O jre-8.exe
    echo "`n`t`tJRE-8 Downloaded, lets start the Installation process"
    start -wait jre-8.exe
    rm jre-8.exe
}else{
    echo "`n`nRequired JRE-8 is Installed`n"
    $jre8
}

# Downloading Burp Suite Professional
if (Test-Path Burp-Suite-Pro.jar){
    echo "Burp Suite Professional JAR file is available.`nChecking its Integrity ...."
    if (((Get-Item Burp-Suite-Pro.jar).length/1MB) -lt 500 ){
        echo "`n`t`tFiles Seems to be corrupted `n`t`tDownloading Burp Suite Professional v2022.8.2 ...."
        wget "https://portswigger.net/burp/releases/startdownload?product=pro&version=2022.8.2&type=Jar" -O "Burp-Suite-Pro.jar"
        echo "`nBurp Suite Professional is Downloaded.`n"
    }else {echo "File Looks fine. Lets proceed for Execution"}
}else {
    echo "`n`t`tDownloading Burp Suite Professional v2022.8.2 ...."
    wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=2022.8.2&type=jar" -O "Burp-Suite-Pro.jar"
    echo "`nBurp Suite Professional is Downloaded.`n"
}

# Creating Burp.bat file with command for execution
if (Test-Path burp.bat) {rm burp.bat} 
$path = "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED -javaagent:`"$pwd\loader.jar`" -noverify -jar `"$pwd\Burp-Suite-Pro.jar`""
$path | add-content -path Burp.bat
echo "`nBurp.bat file is created"


# Creating Burp-Suite-Pro.vbs File for background execution
if (Test-Path Burp-Suite-Pro.vbs) {
   Remove-Item Burp-Suite-Pro.vbs}
echo "Set WshShell = CreateObject(`"WScript.Shell`")" > Burp-Suite-Pro.vbs
add-content Burp-Suite-Pro.vbs "WshShell.Run chr(34) & `"$pwd\Burp.bat`" & Chr(34), 0"
add-content Burp-Suite-Pro.vbs "Set WshShell = Nothing"
echo "`nBurp-Suite-Pro.vbs file is created."

# Remove Additional files
rm Kali_Linux_Setup.sh
del -Recurse -Force .\.github\


# Lets Activate Burp Suite Professional with keygenerator and Keyloader
echo "Reloading Environment Variables ...."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
echo "`n`nStarting Keygenerator ...."
start-process java.exe -argumentlist "-jar keygen.jar"
echo "`n`nStarting Burp Suite Professional"
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED -javaagent:"loader.jar" -noverify -jar "Burp-Suite-Pro.jar"


# Lets Download the latest Burp Suite Professional jar File
echo "`n`t`t 1. Please download latest Burp Suite Professional Jar file from :-:"
echo "`n`t`t https://portswigger.net/burp/releases/startdownload?product=pro&version=&type=Jar"
echo "`n`t`t 2. Replace the existing Burp-Suite-Pro.jar file with downloaded jar file. `n`t Keep previous file name"
