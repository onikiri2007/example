$message = (Get-Item Env:\BUILD_SOURCEVERSIONMESSAGE)
$path = (Get-Item Env:\BUILD_BINARIESDIRECTORY).Value + '\commit.txt'

echo $message > $path