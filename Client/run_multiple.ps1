$godotPath = "C:\PersonalProjects\Godot\Godot.exe"
$output = "C:\PersonalProjects\Godot\_export\Fantasy-Shooter\02_MULTIPLAYER.exe"

#
# Author: @November_Dev
# Modified by: @Hairic_Lilred
#

cmd.exe /c $godotPath --export-debug --no-window "Windows Desktop" $output


for ($i = 0; $i -lt $args[0]; $i++) {
    Start-Process "cmd.exe" -ArgumentList "/c $output --userindex $i" -PassThru
}