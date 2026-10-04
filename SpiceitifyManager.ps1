# ============================================================
# SPICETIFY MANAGER
# PowerShell + WPF GUI
# ============================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

$SpotifyUrl = "https://download.scdn.co/SpotifySetup.exe"
$SpicetifyInstallerUrl = "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1"

# ------------------------------------------------------------
# WINDOW
# ------------------------------------------------------------

[xml]$Xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Spicetify Manager"
    Width="900"
    Height="650"
    MinWidth="800"
    MinHeight="550"
    WindowStartupLocation="CenterScreen"
    Background="#0D0D12"
    Foreground="White">

    <Window.Resources>

        <Style TargetType="Button">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Background" Value="#191923"/>
            <Setter Property="BorderBrush" Value="#30303D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="16,10"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#EEEEF5"/>
        </Style>

    </Window.Resources>

    <Grid Margin="24">

        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- HEADER -->

        <StackPanel Grid.Row="0">

            <TextBlock
                Text="Spicetify Manager"
                FontSize="30"
                FontWeight="Bold"/>

            <TextBlock
                Text="Spotify customization made simple."
                Foreground="#9292A2"
                FontSize="14"
                Margin="0,4,0,20"/>

        </StackPanel>

        <!-- STATUS -->

        <Grid Grid.Row="1">

            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <Border
                Grid.Column="0"
                Background="#15151D"
                BorderBrush="#282832"
                BorderThickness="1"
                CornerRadius="12"
                Padding="18"
                Margin="0,0,8,10">

                <StackPanel>

                    <TextBlock
                        Text="Spotify"
                        FontSize="13"
                        Foreground="#9292A2"/>

                    <TextBlock
                        x:Name="SpotifyStatus"
                        Text="Checking..."
                        FontSize="20"
                        FontWeight="SemiBold"
                        Margin="0,4,0,0"/>

                </StackPanel>

            </Border>

            <Border
                Grid.Column="1"
                Background="#15151D"
                BorderBrush="#282832"
                BorderThickness="1"
                CornerRadius="12"
                Padding="18"
                Margin="8,0,0,10">

                <StackPanel>

                    <TextBlock
                        Text="Spicetify"
                        FontSize="13"
                        Foreground="#9292A2"/>

                    <TextBlock
                        x:Name="SpicetifyStatus"
                        Text="Checking..."
                        FontSize="20"
                        FontWeight="SemiBold"
                        Margin="0,4,0,0"/>

                </StackPanel>

            </Border>

        </Grid>

        <!-- CONTENT -->

        <Grid Grid.Row="2">

            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="2*"/>
                <ColumnDefinition Width="3*"/>
            </Grid.ColumnDefinitions>

            <!-- ACTIONS -->

            <Border
                Grid.Column="0"
                Background="#15151D"
                BorderBrush="#282832"
                BorderThickness="1"
                CornerRadius="12"
                Padding="15"
                Margin="0,5,8,5">

                <StackPanel>

                    <TextBlock
                        Text="Actions"
                        FontSize="18"
                        FontWeight="SemiBold"
                        Margin="5,5,5,10"/>

                    <Button
                        x:Name="InstallButton"
                        Content="Install Spicetify"/>

                    <Button
                        x:Name="UpdateButton"
                        Content="Update Spicetify"/>

                    <Button
                        x:Name="RepairButton"
                        Content="Repair / Reapply"/>

                    <Button
                        x:Name="BackupButton"
                        Content="Create Backup"/>

                    <Button
                        x:Name="RestoreButton"
                        Content="Restore Backup"/>

                    <Button
                        x:Name="SpotifyButton"
                        Content="Install Spotify"/>

                    <Separator Margin="5,15"/>

                    <Button
                        x:Name="LaunchButton"
                        Content="Launch Spotify"/>

                    <Button
                        x:Name="FolderButton"
                        Content="Open Spicetify Folder"/>

                </StackPanel>

            </Border>

            <!-- LOG -->

            <Border
                Grid.Column="1"
                Background="#0A0A0F"
                BorderBrush="#282832"
                BorderThickness="1"
                CornerRadius="12"
                Padding="12"
                Margin="8,5,0,5">

                <Grid>

                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <TextBlock
                        Grid.Row="0"
                        Text="Activity"
                        FontSize="18"
                        FontWeight="SemiBold"
                        Margin="4,4,4,10"/>

                    <ScrollViewer
                        Grid.Row="1"
                        x:Name="LogScroller"
                        VerticalScrollBarVisibility="Auto">

                        <TextBox
                            x:Name="LogBox"
                            IsReadOnly="True"
                            TextWrapping="Wrap"
                            Background="Transparent"
                            BorderThickness="0"
                            Foreground="#BDBDCB"
                            FontFamily="Consolas"
                            FontSize="12"/>

                    </ScrollViewer>

                    <ProgressBar
                        Grid.Row="2"
                        x:Name="Progress"
                        Height="5"
                        Margin="0,12,0,0"
                        Minimum="0"
                        Maximum="100"
                        Value="0"/>

                </Grid>

            </Border>

        </Grid>

        <!-- FOOTER -->

        <Grid Grid.Row="3" Margin="0,12,0,0">

            <TextBlock
                x:Name="FooterStatus"
                Text="Ready"
                Foreground="#777786"
                VerticalAlignment="Center"/>

            <Button
                x:Name="CloseButton"
                Content="Close"
                Width="90"
                HorizontalAlignment="Right"/>

        </Grid>

    </Grid>

</Window>
"@

# ------------------------------------------------------------
# LOAD GUI
# ------------------------------------------------------------

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)

# ------------------------------------------------------------
# CONTROLS
# ------------------------------------------------------------

$SpotifyStatus   = $Window.FindName("SpotifyStatus")
$SpicetifyStatus = $Window.FindName("SpicetifyStatus")
$FooterStatus    = $Window.FindName("FooterStatus")
$LogBox          = $Window.FindName("LogBox")
$LogScroller     = $Window.FindName("LogScroller")
$Progress        = $Window.FindName("Progress")

$InstallButton   = $Window.FindName("InstallButton")
$UpdateButton    = $Window.FindName("UpdateButton")
$RepairButton    = $Window.FindName("RepairButton")
$BackupButton    = $Window.FindName("BackupButton")
$RestoreButton   = $Window.FindName("RestoreButton")
$SpotifyButton   = $Window.FindName("SpotifyButton")
$LaunchButton    = $Window.FindName("LaunchButton")
$FolderButton    = $Window.FindName("FolderButton")
$CloseButton     = $Window.FindName("CloseButton")

# ------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------

function Write-Log {
    param(
        [string]$Message
    )

    $LogBox.AppendText("[$(Get-Date -Format 'HH:mm:ss')] $Message`r`n")
    $LogBox.ScrollToEnd()
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-Status {
    param(
        [string]$Text
    )

    $FooterStatus.Text = $Text
}

# ------------------------------------------------------------
# SPOTIFY DETECTION
# ------------------------------------------------------------

function Test-Spotify {

    $Paths = @(
        "$env:APPDATA\Spotify\Spotify.exe",
        "$env:LOCALAPPDATA\Spotify\Spotify.exe",
        "$env:ProgramFiles\Spotify\Spotify.exe",
        "${env:ProgramFiles(x86)}\Spotify\Spotify.exe"
    )

    foreach ($Path in $Paths) {

        if ($Path -and (Test-Path $Path)) {
            return $true
        }
    }

    try {

        $Command = Get-Command spotify.exe -ErrorAction SilentlyContinue

        if ($Command) {
            return $true
        }

    } catch {}

    return $false
}

# ------------------------------------------------------------
# SPICETIFY DETECTION
# ------------------------------------------------------------

function Test-Spicetify {

    try {

        $Command = Get-Command spicetify -ErrorAction SilentlyContinue

        if ($Command) {
            return $true
        }

    } catch {}

    $PossiblePaths = @(
        "$env:USERPROFILE\.spicetify",
        "$env:APPDATA\spicetify"
    )

    foreach ($Path in $PossiblePaths) {

        if (Test-Path $Path) {
            return $true
        }
    }

    return $false
}

# ------------------------------------------------------------
# REFRESH STATUS
# ------------------------------------------------------------

function Refresh-Status {

    if (Test-Spotify) {

        $SpotifyStatus.Text = "● Installed"
        $SpotifyStatus.Foreground = "#6DDB8B"

        $SpotifyButton.Content = "Reinstall Spotify"

    }
    else {

        $SpotifyStatus.Text = "● Not Installed"
        $SpotifyStatus.Foreground = "#FF7070"

        $SpotifyButton.Content = "Install Spotify"
    }

    if (Test-Spicetify) {

        $SpicetifyStatus.Text = "● Installed"
        $SpicetifyStatus.Foreground = "#6DDB8B"

    }
    else {

        $SpicetifyStatus.Text = "● Not Installed"
        $SpicetifyStatus.Foreground = "#FF7070"

    }
}

# ------------------------------------------------------------
# RUN COMMAND
# ------------------------------------------------------------

function Invoke-CommandLogged {

    param(
        [string]$File,
        [string[]]$Arguments
    )

    Write-Log "Running: $File $($Arguments -join ' ')"

    try {

        & $File @Arguments 2>&1 | ForEach-Object {

            Write-Log "$_"

        }

        return $LASTEXITCODE

    }
    catch {

        Write-Log "ERROR: $($_.Exception.Message)"

        return 1
    }
}

# ------------------------------------------------------------
# INSTALL SPOTIFY
# ------------------------------------------------------------

function Install-Spotify {

    Set-Status "Installing Spotify..."
    $Progress.Value = 10

    Write-Log "Spotify installation started."

    $Installer = Join-Path $env:TEMP "SpotifySetup.exe"

    try {

        Write-Log "Downloading official Spotify installer..."

        Invoke-WebRequest `
            -Uri $SpotifyUrl `
            -OutFile $Installer `
            -UseBasicParsing

        $Progress.Value = 40

        Write-Log "Download complete."

        Write-Log "Launching Spotify installer..."

        Start-Process `
            -FilePath $Installer `
            -Wait

        $Progress.Value = 80

        Write-Log "Spotify installer finished."

        Start-Sleep -Seconds 2

        if (Test-Spotify) {

            Write-Log "Spotify detected successfully."
            $Progress.Value = 100
            Set-Status "Spotify installed."

        }
        else {

            Write-Log "Spotify could not be detected."
            Set-Status "Spotify installation failed."

        }

    }
    catch {

        Write-Log "ERROR: $($_.Exception.Message)"
        Set-Status "Spotify installation failed."
    }

    Refresh-Status
}

# ------------------------------------------------------------
# INSTALL SPICETIFY
# ------------------------------------------------------------

function Install-Spicetify {

    if (-not (Test-Spotify)) {

        Write-Log "Spotify is not installed."
        Write-Log "Install Spotify before installing Spicetify."

        Set-Status "Spotify required."
        return
    }

    Set-Status "Installing Spicetify..."
    $Progress.Value = 10

    Write-Log "Starting Spicetify installation."

    try {

        Write-Log "Downloading official Spicetify installer..."

        $Script = Invoke-WebRequest `
            -Uri $SpicetifyInstallerUrl `
            -UseBasicParsing

        $Progress.Value = 35

        Write-Log "Installer downloaded."

        Write-Log "Executing official installer..."

        Invoke-Expression $Script.Content

        $Progress.Value = 85

        Start-Sleep -Seconds 2

        if (Test-Spicetify) {

            Write-Log "Spicetify detected successfully."
            $Progress.Value = 100
            Set-Status "Spicetify installed."

        }
        else {

            Write-Log "Spicetify was not found in PATH."
            Write-Log "You may need to restart the application."

            Set-Status "Installed, PATH refresh may be required."
        }

    }
    catch {

        Write-Log "ERROR: $($_.Exception.Message)"
        Set-Status "Spicetify installation failed."
    }

    Refresh-Status
}

# ------------------------------------------------------------
# UPDATE
# ------------------------------------------------------------

function Update-Spicetify {

    if (-not (Test-Spicetify)) {

        Write-Log "Spicetify is not installed."
        return
    }

    Set-Status "Updating Spicetify..."
    $Progress.Value = 20

    Write-Log "Running spicetify update..."

    $Result = Invoke-CommandLogged `
        -File "spicetify" `
        -Arguments @("update")

    if ($Result -eq 0) {

        Write-Log "Update completed."
        $Progress.Value = 100
        Set-Status "Update complete."

    }
    else {

        Write-Log "Update returned exit code $Result."
        Set-Status "Update failed."
    }
}

# ------------------------------------------------------------
# REPAIR / APPLY
# ------------------------------------------------------------

function Repair-Spicetify {

    if (-not (Test-Spicetify)) {

        Write-Log "Spicetify is not installed."
        return
    }

    Set-Status "Repairing Spicetify..."
    $Progress.Value = 20

    Write-Log "Running backup..."
    Invoke-CommandLogged "spicetify" @("backup")

    $Progress.Value = 50

    Write-Log "Applying Spicetify..."
    $Result = Invoke-CommandLogged "spicetify" @("apply")

    if ($Result -eq 0) {

        $Progress.Value = 100
        Set-Status "Repair complete."
        Write-Log "Spicetify applied successfully."

    }
    else {

        Set-Status "Repair failed."
    }
}

# ------------------------------------------------------------
# BACKUP
# ------------------------------------------------------------

function Backup-Spicetify {

    if (-not (Test-Spicetify)) {

        Write-Log "Spicetify is not installed."
        return
    }

    Set-Status "Creating backup..."

    $Result = Invoke-CommandLogged `
        -File "spicetify" `
        -Arguments @("backup")

    if ($Result -eq 0) {

        Set-Status "Backup complete."
        Write-Log "Backup completed successfully."

    }
    else {

        Set-Status "Backup failed."
    }
}

# ------------------------------------------------------------
# RESTORE
# ------------------------------------------------------------

function Restore-Spicetify {

    if (-not (Test-Spicetify)) {

        Write-Log "Spicetify is not installed."
        return
    }

    Set-Status "Restoring backup..."

    $Result = Invoke-CommandLogged `
        -File "spicetify" `
        -Arguments @("restore")

    if ($Result -eq 0) {

        Set-Status "Restore complete."
        Write-Log "Restore completed successfully."

    }
    else {

        Set-Status "Restore failed."
    }
}

# ------------------------------------------------------------
# BUTTON EVENTS
# ------------------------------------------------------------

$SpotifyButton.Add_Click({

    Install-Spotify

})

$InstallButton.Add_Click({

    Install-Spicetify

})

$UpdateButton.Add_Click({

    Update-Spicetify

})

$RepairButton.Add_Click({

    Repair-Spicetify

})

$BackupButton.Add_Click({

    Backup-Spicetify

})

$RestoreButton.Add_Click({

    Restore-Spicetify

})

$LaunchButton.Add_Click({

    if (Test-Spotify) {

        Write-Log "Launching Spotify..."

        Start-Process "spotify.exe"

        Set-Status "Spotify launched."

    }
    else {

        Write-Log "Spotify is not installed."

        Set-Status "Spotify not installed."
    }

})

$FolderButton.Add_Click({

    $Folder = "$env:USERPROFILE\.spicetify"

    if (Test-Path $Folder) {

        Start-Process explorer.exe $Folder

        Write-Log "Opened Spicetify folder."

    }
    else {

        Write-Log "Spicetify folder was not found."
    }

})

$CloseButton.Add_Click({

    $Window.Close()

})

# ------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------

Write-Log "Spicetify Manager started."
Write-Log "Checking installation status..."

Refresh-Status

Write-Log "Ready."

Set-Status "Ready."

# ------------------------------------------------------------
# SHOW WINDOW
# ------------------------------------------------------------

$Window.ShowDialog() | Out-Null