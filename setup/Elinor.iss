[Setup]
AppName=Elinor
AppVersion=1.0
WizardStyle=modern
DefaultDirName={autopf}\Elinor
DefaultGroupName=Elinor
UninstallDisplayIcon={app}\setup\Elinor.ico
Compression=lzma2
SolidCompression=yes
OutputDir=D:\Dev
OutputBaseFilename=ElinorSetup
SetupIconFile=Elinor.ico

[Files]
Source: "..\Elinor.exe"; DestDir: "{app}"
Source: "..\Bass.dll"; DestDir: "{app}"
Source: "..\resources\*"; DestDir: "{app}\resources"
Source: "..\resources\music\*"; DestDir: "{app}\resources\music"
Source: "..\resources\sounds\*"; DestDir: "{app}\resources\sounds"

[Icons]
Name: "{group}\Elinor"; Filename: "{app}\setup\Elinor.ico"
