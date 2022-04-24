::------------------------------------------------------------------------------
:: NAME
::     UnitConvert.bat - Unit Convert
::
:: DESCRIPTION
::     Unit Convert is a batch script created to quickly
::     get information about a desired file(s).
::
:: KNOWN BUGS
::     Characters & and ! in the file name are not supported.
::
:: AUTHOR
::     IB_U_Z_Z_A_R_Dl
::
:: CREDITS
::     @anic17   - Initial project idea and name.
::     @Grub4K and @sintrode - General helping in the project.
::     @Grub4K   - Command line arguments parsing and passing.
::     @sintrode - Helped for the attribute descriptions.
::     @<Tim>    - Owner of "Number.cmd": https://github.com/timlg07/Number.cmd
::
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
::
:: TODO:
:: Make all WMIC commands powershell friendly for W.11 support.
:: [Kilobytes   KB]  >  28.7 but its 29,383 ?
:: 169/100% (don't know when exactly this one happen)
@echo off

setlocal DisableDelayedExpansion
pushd "%~dp0"
for /f %%A in ('forfiles /m "%~nx0" /c "cmd /c echo 0x08"') do (
    set "\B=%%A"
)
setlocal EnableDelayedExpansion

set TITLE=Unit Convert.
title !TITLE!
call :WINDOWS_TERMINAL_DETECTION
cls
if not defined WINDOWS_TERMINAL (
    mode 170,50
)
>nul 2>&1 powershell /?
if !errorlevel!==0 (
    set powershell=1
) else (
    if defined powershell (
        set powershell=
    )
)

:: -------------------ARGUMENTS-------------------
set files=0
for %%A in (%*) do (
    set p=%%~A
    if "!p:~0,1!"=="-" (
        for %%B in (FI FS R V) do (
            if /i "!p:~1!"=="%%B" (
                set args=!args! -%%B
                set %%B=1
            )
        )
    ) else (
        set /a files+=1
        set files_[!files!]=%%~A
    )
)
if !files! gtr 1 (
    for /l %%A in (1 1 !files!) do (
        start cmd /c ""%~f0" "!files_[%%A]!"!args!"
    )
    exit 0
)
set "sp=                   "
for %%A in ("!files_[1]!") do (
    set "File=%%~nxA"
    set "FileExtension=%%~xA"
    set "FilePath=%%~fA"
    set "FileSize=%%~zA"
    set "Attributes=%%~aA"
)
if "!File!"=="" (
    set error=ERROR: Missing arguments.
    goto :EXIT
)
if not exist "!FilePath!" (
    set error=ERROR: Cannot find file/folder: "!FilePath!".
    goto :EXIT
)
if defined FilePath (
    set "WMIC_FilePath=!FilePath:\=\\!"
)
if not defined FileSize (
    for /f "tokens=2delims==" %%A in ('WMIC DATAFILE where "Name='!WMIC_FilePath!'" get FileSize /format:list') do (
        set FileSize=%%A
    )
)
if !FileSize! lss 100000000 (
    set scan=1
)
if defined V (
    set scan=1
)
echo:
set cv=26
if defined FS (
    if not defined FI (
        set cv=10
        goto :FILE_SIZE
    )
)
if defined FI (
    if not defined FS (
        set cv=16
    )
)

:: -----------------CHECK FOLDERS-----------------
:: https://www.robvanderwoude.com/battech_ifexistfolder.php
set NUL=NUL
if "!OS!"=="Windows_NT" (
    set NUL=
)
if exist "!FilePath!\!NUL!" (
    if defined R (
        for /f "delims=" %%A in ('2^>nul dir "!FilePath!" /a:-d /b /s') do (
            start "" cmd /c ""%~f0" "%%~A""
        )
    ) else (
        for /f "delims=" %%A in ('2^>nul dir "!FilePath!" /a:-d /b') do (
            start "" cmd /c ""%~f0" "!FilePath!\%%~A""
        )
    )
    exit 0
)
:: ---------------FILE INFORMATION----------------
echo File information:  [Name          ]  ^>  !File!
call :TITLE_ADD_PERCENTAGE
echo !sp![Path          ]  ^>  !FilePath!
call :TITLE_ADD_PERCENTAGE
if defined PID (
    set PID=
)
for /f %%A in ('2^>nul WMIC PROCESS where "Name='!File!'" get ProcessID ^| findstr /brc:"[0-9]"') do (
    set "PID=!PID!%%A,"
)
if defined PID (
    if "!PID:~-1!"=="," (
        set "PID=!PID:~0,-1!"
    )
    if defined PID (
        echo !sp![PID           ]  ^>  !PID!
    )
)
call :TITLE_ADD_PERCENTAGE
:: attrib.exe:A  SHR OI  X PU
:: %%~a      :drahscotl-x
for /f "delims=" %%A in ('2^>nul attrib "!FilePath!"') do (
    set "_Attributes=%%A"
)
for /f "tokens=1*delims=:" %%A in ("$!_Attributes!") do (
    if not "%%B"=="" (
        set "_Attributes=%%A"
        set "_Attributes=!_Attributes:~1,-1!"
        if defined _Attributes (
            set "Attributes=!Attributes!!_Attributes!"
        )
    )
    if defined _Attributes (
        set _Attributes=
    )
)
if defined Attributes (
    for %%A in (-," ") do (
        if defined Attributes (
            set "Attributes=!Attributes:%%~A=!"
        )
    )
    if defined Attributes (
        <nul set /p=.!\B!!sp![Attribute^(s^)  ]  ^>
        for /f "delims==" %%A in ('2^>nul set attribute_[') do (
            set %%A=
        )
        set attribute_[A]=A`Archive`^(The file or directory is marked to be included in incremental backup or removal operation.^)
        set attribute_[B]=B`SMR Blob`^(Unfortunately, UnitConvert could not find a description for 'SMR Blob'.^)
        set attribute_[C]=C`Compressed`^(The file is compressed.^)
        set attribute_[D]=D`Directory`^(The file is a directory.^)
        set attribute_[E]=E`Encrypted`^(The file or directory is encrypted.^)
        set attribute_[H]=H`Hidden`^(The file is hidden, and is not included in an ordinary directory listing.^)
        set attribute_[I]=I`Not Content-Indexed`^(The file or directory is not to be indexed by the content indexing service.^)
        set attribute_[L]=L`Reparse Point`^(The file or directory has an associated re-parse point, or is a symbolic link.^)
        set attribute_[N]=N`Not Indexed`^(The file is not indexed on the host device.^)
        set attribute_[O]=O`Offline`^(The file data is physically moved to offline storage ^(Remote Storage^).^)
        set attribute_[P]=P`Sparse`^(The file is a sparse file.^)
        set attribute_[Q]=Q`Sparse File`^(Unfortunately, UnitConvert could not find a description for 'Sparse File'.^)
        set attribute_[R]=R`Read-only`^(The file is read-only.^)
        set attribute_[S]=S`System`^(The file or directory is a system file.^)
        set attribute_[T]=T`Temporary`^(The file is used for temporary storage.^)
        set attribute_[U]=U`Unpinned`^(Unfortunately, UnitConvert could not find a description for 'Unpinned'.^)
        set attribute_[V]=V`Integrity`^(The directory or user data stream is configured with integrity ^(only supported on ReFS volumes^).^)
        set attribute_[X]=X`No scrub file`^(The user data stream not to be read by the background data integrity scanner ^(AKA scrubber^). When set on a directory it only provides inheritance.^)
        set attribute_[Z]=Z`Alternate Data Streams`^(Unfortunately, UnitConvert could not find a description for 'Alternate Data Streams'.^)
        set counter=0
        for /f %%A in ('set attribute_[') do (
            set /a counter+=1
        )
        set first=1
        for /l %%A in (0,1,!counter!) do (
            for %%B in ("!Attributes:~%%A,1!") do (
                if defined attribute_[%%~B] (
                    if not defined counts_[%%~B] (
                        set counts_[%%~B]=1
                        for /f "tokens=1-3delims=`" %%C in ("!attribute_[%%~B]!") do (
                            if defined first (
                                set first=
                                echo   %%C [%%D] %%E
                            ) else (
                                echo !sp!                  ^>  %%C [%%D] %%E
                            )
                            set attribute_[%%C]=
                        )
                    )
                )
            )
        )
        for /f "delims==" %%A in ('2^>nul set attribute_[') do (
            set %%A=
        )
    )
)
call :WMIC CreationDate "Date Created  " D
call :WMIC LastAccessed "Date Acceeded " D
call :WMIC LastModified "Date Modified " D
for /f "tokens=3*" %%A in ('2^>nul dir "!FilePath!" /a-d /q ^| find /i "!File!"') do (
    if not "%%B"=="" (
        set "owner=%%B"
        set "owner=!owner:~0,23!"
        goto :EARLY_EXIT_GET_OWNER
    )
)
:EARLY_EXIT_GET_OWNER
echo !sp![Owner         ]  ^>  !owner!
call :TITLE_ADD_PERCENTAGE
if "!FileExtension!"==".exe" (
    call :POWERSHELL InternalName "InternalName  "
    call :POWERSHELL OriginalFilename "OriginalName  "
    call :WMIC Manufacturer "Manufacturer  " s
    call :POWERSHELL FileDescription "Description   "
    call :POWERSHELL Product "Product       "
    call :POWERSHELL FileVersion "FileVersion   "
    if not defined FileVersion (
        call :WMIC Version "FileVersion   " s
    )
    call :POWERSHELL ProductVersion "ProductVersion"
    call :POWERSHELL Language "Language      "
)
call :WMIC FileType "Type          "
call :WMIC archive  "Archived      "
call :WMIC Compressed "Compressed    "
call :WMIC Encrypted "Encrypted     "
call :WMIC System "System        "
call :WMIC Hidden "Hidden        "
call :WMIC Readable "Readable      "
call :WMIC Writeable  "Writeable     "
call :WMIC FSName "FSName        "
call :HASH MD2 "MD2      "
call :HASH MD4 "MD4      "
call :HASH MD5 "MD5      "
call :HASH SHA1 "SHA1     "
call :HASH SHA256 "SHA256   "
call :HASH SHA384 "SHA384   "
call :HASH SHA512 "SHA512   "
echo:
if defined FI (
    if not defined FS (
        goto :EXIT
    )
)

:: -------------------FILE SIZE-------------------
:FILE_SIZE
if not exist Number.cmd (
    call :DOWNLOAD_NUMBER_CMD || (
        echo:
        echo ERROR: Impossible to found or download "Number.cmd"
        echo Please download "Number.cmd" in "%~dp0" folder.
        start "" "https://tim-greller.de/git/number/Number.cmd"
        goto :EXIT
    )
)
set "s= "
call Number.cmd xf = !FileSize! * 8 f:.
if !xf! gtr 1 (
    set s=s
)
echo File size:         [Bit!s!         b]  ^>  !xf!
call :TITLE_ADD_PERCENTAGE
if !FileSize! lss 2 (
    set "s= "
)
echo !sp![Byte!s!        B]  ^>  !FileSize!
call :TITLE_ADD_PERCENTAGE
if !FileSize! gtr 0 (
    set s=s
)
call :NUMBER_CMD KB "Kilobyte!s! " !FileSize!
call :NUMBER_CMD MB "Megabyte!s! " !x!
call :NUMBER_CMD GB "Gigabyte!s! " !x!
call :NUMBER_CMD TB "Terabyte!s! " !x!
call :NUMBER_CMD PB "Petabyte!s! " !x!
call :NUMBER_CMD EB "Exabyte!s!  " !x!
call :NUMBER_CMD ZB "Zettabyte!s!" !x!
call :NUMBER_CMD YB "Yottabyte!s!" !x!

:EXIT
if defined error (
    call :HELP
    echo !error!
) else (
    set el=File "!File!" scan completed successfully.
    echo:
    <nul set /p=!el!
    echo:
)
echo:
<nul set /p=Press {ANY KEY} to exit...
>nul pause
exit /b 0

:WMIC
for /f "tokens=2delims==" %%A in ('WMIC DATAFILE where "Name='!WMIC_FilePath!'" get %1 /format:list') do (
    if "%3"=="D" (
        set stamp=%%A
        set year=!stamp:~0,4!
        set month=!stamp:~4,2!
        set days=!stamp:~6,2!
        set hours=!stamp:~8,2!
        set minutes=!stamp:~10,2!
        set seconds=!stamp:~12,2!
        if defined v (
            set timezone= !stamp:~15!
        )
        echo !sp![%~2]  ^>  !year!/!month!/!days! !hours!:!minutes!:!Seconds!!timezone!
    ) else (
        <nul set /p=%%A| >nul findstr [A-Z0-9] && (
            echo !sp![%~2]  ^>  %%A
        )
    )
)
if not "%3"=="s" (
    call :TITLE_ADD_PERCENTAGE
)
exit /b

:POWERSHELL
if not defined powershell (
    exit /b
)
for /f "tokens=2*" %%A in (
    '^>nul chcp 437^& 2^>nul powershell Get-ItemProperty -Path "'!FilePath!'" ^^^^^| Format-list -Property VersionInfo -Force ^| find "%1:"^& ^>nul chcp 65001'
) do (
    set %1=%%A %%B
)
if defined %1 (
    echo !sp![%~2]  ^>  !%1!
)
exit /b

:HASH
if not defined scan (
    exit /b
)
if defined hash (
    set hash=
)
for /f "delims=" %%A in ('certutil -hashfile "!FilePath!" %1 ^| findstr /rxc:"[a-f0-9 ]*"') do (
    if not defined hash (
        set "hash=%%A"
    )
)
if defined hash (
    set "hash=!hash: =!"
)
echo !sp![Hash %~2]  ^>  !hash!
exit /b

:NUMBER_CMD
for %%A in (0,0.^(...^)) do (
    if "!xf!"=="%%A" (
        echo !sp![%~2  %1]  ^>  !xf!
        call :TITLE_ADD_PERCENTAGE
        exit /b
    )
)
call Number.cmd x = %3 * 9765625e-10
call Number.cmd xf = !x! * 1 f:.
if not defined V (
    if "!xf:~0,3!"=="0.0" (
        set xf=0.^(...^)
    )
    if not "!xf:~0,3!"=="0.(" (
        for /f "tokens=1,2delims=." %%A in ("!xf!") do (
            set first=%%A
            set second=%%B
        )
        if defined second (
            if !second:~1^,1! geq 5 (
                set /a rounded=!second:~0,1!+1
            ) else (
                set /a rounded=!second:~0,1!
            )
            set xf=!first!.!rounded!
            set xf=!xf:.0=!
        )
    )
)
echo !sp![%~2  %1]  ^>  !xf!
call :TITLE_ADD_PERCENTAGE
exit /b

:TITLE_ADD_PERCENTAGE
set /a cn+=1, el=cn*100/cv
title !TITLE! Scanning File "!File!"  ^|  [!el!/100%%] completed.
exit /b

:WINDOWS_TERMINAL_DETECTION
set WINDOWS_TERMINAL=1
if defined WT_SESSION (
    goto :SKIP_WINDOWS_TERMINAL
)
2>nul reg query "HKEY_CURRENT_USER\Console\%%%%Startup" /v "DelegationTerminal" | >nul find "{00000000-0000-0000-0000-000000000000}" && (
    set WINDOWS_TERMINAL=
)
:SKIP_WINDOWS_TERMINAL
if defined WINDOWS_TERMINAL (
    2>nul tasklist /nh /fo csv /fi "imagename eq WindowsTerminal.exe" | >nul find /i """WindowsTerminal.exe""" && (
        2>nul tasklist /nh /fo csv /fi "imagename eq OpenConsole.exe" | >nul find /i """OpenConsole.exe""" || (
            set WINDOWS_TERMINAL=
        )
    ) || (
        set WINDOWS_TERMINAL=
    )
)
exit /b

:DOWNLOAD_NUMBER_CMD
curl -fkLs "https://tim-greller.de/git/number/Number.cmd" -o "Number.cmd"
call :CHECK_DOWNLOAD_NUMBER_CMD && (
    exit /b 0
)
if defined powershell (
    >nul chcp 437
    powershell Invoke-WebRequest -Uri "'https://tim-greller.de/git/number/Number.cmd'" -OutFile "'Number.cmd'"
    >nul chcp 65001
)
call :CHECK_DOWNLOAD_NUMBER_CMD && (
    exit /b 0
)
certutil -urlcache -split -f "https://tim-greller.de/git/number/Number.cmd" "Number.cmd"
call :CHECK_DOWNLOAD_NUMBER_CMD && (
    exit /b 0
)
bitsadmin /transfer someDownload /download /priority high "https://tim-greller.de/git/number/Number.cmd" "%~dp0Number.cmd"
call :CHECK_DOWNLOAD_NUMBER_CMD && (
    exit /b 0
)
exit /b 1

:CHECK_DOWNLOAD_NUMBER_CMD
if exist Number.cmd (
    if !errorlevel!==0 (
        exit /b 0
    ) else (
        del Number.cmd
    )
)
exit /b 1

:HELP
echo:
echo Unit Convert is a batch script created to quickly get information about a desired file(s).
echo The idea and project were born in https://discord.gg/eCMBHUB and https://discord.gg/GSVrHag.
echo:
echo:
echo Usage:             - Drag and Drop your desired file(s)/folder(s) into "UnitConvert.bat"
echo !sp!  or "UnitConvert.bat" "FileName1.txt" "FileName2.exe"
echo:
echo Arguments:         -FI (File Information)
echo !sp!-FS (File Size)
echo !sp!-R (Recurse subfolders)
echo !sp!-V (Verbose)
echo !sp!Tip: You can combine all arguments together.
echo:
echo:
exit /b