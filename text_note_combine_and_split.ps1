# modes
## combine - take files in a directory and combines them into a 'combined_notes.txt' file
## split - take a file 'combined_notes.txt' and splits it into different files at a specific separator

#Param(
#    [Parameter(Mandatory=$true,
#    ValueFromPipeline=$true)]
#    [String]
#    $mode
#)

$global:mode = ""

#  ============== Form to display GUI =======================================
 Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -Assembly System.Drawing 
$Form = New-Object system.Windows.Forms.Form
                         
[int32]$height = 60
[int32]$width = 220
$Form.ClientSize                 = "$width,$height"
$Form.text                       = "Combine or Split Note Files"
$Form.TopMost                    = $true

$combine_button = New-Object system.Windows.Forms.Button
$combine_button.width                   = 100
$combine_button.height                  = 50
$combine_button.text					= "Combine"
$combine_button.location                = New-Object System.Drawing.Point(10,10)
$combine_button.Font                    = 'Microsoft Sans Serif,10'
$combine_button.Add_Click({
    $global:mode = "combine"
    $Form.Close()
})

$split_button = New-Object system.Windows.Forms.Button
$split_button.width                  = 100
$split_button.height                 = 50
$split_button.text					= "Split"
$split_button.location               = New-Object System.Drawing.Point(110,10)
$split_button.Font                   = 'Microsoft Sans Serif,10'
$split_button.Add_Click({
    $global:mode = "split"
    $Form.Close()
})
$Form.controls.Add($combine_button)
$Form.controls.Add($split_button)
#Start form 
[void]$Form.ShowDialog()

$folder_browser = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$folder_browser.ShowDialog()

$notes_path = $folder_browser.SelectedPath

$output_file = "compiled_notes.txt"
$output_file_path = "$notes_path\$output_file"
$file_separator = "##### "

if  ($global:mode -eq "combine") {
	# Get files in the current directory and sort them by the file title
	$files = Get-ChildItem -Path $notes_path | Where-Object { $_.Name -match "txt" } | sort    

	# Iterate over each file in the $files array
	ForEach ($input_file in $files) {
		# get the content of the input file and append it to the output file
        $input_file_path = "$notes_path\$input_file"

        # check if the 'combine' command is run when there is already a 'compiled_notes.txt' file present, skip this file
        if ($input_file_path -eq $output_file_path) {
            continue
        }

        # put a leading $file_separator and file name before the file content
        Write-Output "$file_separator$input_file" | Out-File -Append -Encoding ascii $output_file_path

		# Add the content of each file to the output file
		Get-Content $input_file_path | Out-File -Append -Encoding ascii $output_file_path

        # Remove that input file
        Remove-Item $input_file_path
	}
} elseif  ($global:mode -eq "split") {
    # Get the content of the output file
    $file_content = Get-Content $output_file_path
    $file_name = ""


    # go throught the file line by line and check if the $file_separator is at the beginning of the line
	ForEach ($line in $file_content) {
        # check if the beginning of the line matches the file separator
        if ($line -match "^$file_separator(.+)") {
            # create a new file with the content after the $file_separator
            # set the name of the file based on the split line value
            $file_name = $Matches[1]
            $file_name_path = "$notes_path\$file_name"

            # if the file exists, remove the file
            if (Get-Item $file_name_path -ErrorAction Ignore) {
                Remove-Item $file_name_path
            }
        } elseif ($file_name -ne "") {
            # add content to the file
            Write-Output $line | Out-File -Append $file_name_path
        }
    }

    # remove the combined content file after splitting it into separate files
    Remove-Item $output_file_path		
}