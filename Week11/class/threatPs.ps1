#Array of websites containing threat intel
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules', 'https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

#Loop through the URL's for the rules list

foreach ($u in $drop_urls) {

    #Extract the filename
    $temp = $u.split("/")
    #Split takes a string and turns it into an array

    #The last element in the array plucked off is the filename
    $file_name = $temp[-1]

    if (Test-Path $file_name){

        continue
    } else {

    
        #Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name

        }#Close the if statement

    }#close the foreach loop

#Array containing the filename
$input_paths = @('.\compromised-ips.txt', '.\emerging-botcc.rules')
#Extract the IP Adresses
$regex_drop = '\b\d{1,3}\. \d{1,3}\. \d{1,3}\. \d{1,3}\b'

#Append the IP Address to the temporary IP list
select-string -Path $input_paths -Pattern $regex_drop | `
ForEach-Object { $_.Matches } | `
ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"

#Get the IP addresses discovered, loop through and replace the beginning of the line with the IPTables syntax
#After the IP address, add the remaining IPTables syntax and save the results to a file
#iptables -A INPUT -s 108.191.2.72 -j DROP
(Get-COntent -Path ".\ips-bad.tmp") | % `
{ $_ -replace "^","iptables -A INPUT -s " -replace "$", " -j DROP"} | `
Out-file -FilePath "iptables.bash"

