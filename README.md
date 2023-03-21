# Overview:
 The following scripts will query an Apple Directory group of your choosing, and generates a csv template that can be used to create and/or update (or disable) the DemoKit on-prem Active Directory user objects.

## Usage

`export.sh`

Replace the value of the ADGROUP variable to specify a different Apple Directory group to the recommended "DemoKit ENT User Accounts", and any user attribute variables you'd like to change. The script requires no additional parameters, and will populate the `users.csv` accordingly.

The ADGROUP variable expects the unique 'RealName/RecordName' OD group attribute, or simply put: just copy and paste the group name from Apple Directory.

For best results, make sure to delete or move the users.csv file out of the script directory before each execution, otherwise it will add the output of the run to the bottom of an existing document.

`import_users.ps1`

Transfer the powershell script and the now populated users.csv file to a domain controller, and run the following on the command line:

`.\import_users.ps1 -CsvFilePath .\users.csv -OrganizationalUnit "FE"`

Change the -OrganizationalUnit parameter as needed, but for DemoKit purposes you should not need to do this unless changing the marketing approved user list OU, which is 'Approved'