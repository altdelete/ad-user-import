#!/bin/bash

# Overview:
# This script queries an Apple Directory group and exports it's members (including members of nested groups) into a csv template that can be used to create and/or update the DemoKit on-prem Active Directory user objects.
#
# Usage
# Simply replace the values of the variables in the section below with whatever data you want populated into the corresponding csv file headers.
#
# The ADGROUP variable expects the unique 'RealName/RecordName' OD group attribute, or simply put: just copy and paste the group name from Apple Directory.
#
# For best results, make sure to delete or move the users.csv file out of the script directory before each execution, otherwise it will add the output of the run to the bottom of an existing document.

# Variables
ADGROUP="DemoKit ENT User Accounts"
PASSWORD='korpug-6haqzi-ciCj5n'
TITLE="Staff"
DEPARTMENT="FE"

# Query nod.apple.com for GroupMemebership and dump into an array
SHORTNAMES=( `dscl /LDAPv3/nod.apple.com -read Groups/"$ADGROUP" GroupMembership | cut -d ":" -f2` )

# Create users.csv with appropriate attribute headers for importing into AD via powershell.
echo "displayName, sAMAccountName, userPrincipalName, passwordProfile, givenName, surname, jobTitle, department" >> users.csv

# Query nod.apple.com for each shortname's FirstName, LastName, and email address, transform email to create UPN then dump into arrays
for i in ${SHORTNAMES[@]}
do
	echo "Adding $i to array"
	EMAILADDRESS=( `dscl /LDAPv3/nod.apple.com -read Users/$i EMailAddress | cut -d ":" -f2 | sed 's/@[^,]*/@pretendco.com/'`  )
	FIRSTNAMES=( `dscl /LDAPv3/nod.apple.com -read Users/$i FirstName | cut -d ":" -f2` )
	LASTNAMES=( `dscl /LDAPv3/nod.apple.com -read Users/$i LastName | cut -d ":" -f2` )
	REALNAME=( ${FIRSTNAMES[@]}' '${LASTNAMES[@]} )

# complete users.csv with the appropriate attributes and substitutions.
	echo ${REALNAME[@]}"," ${EMAILADDRESS[@]%@*}","${EMAILADDRESS[@]}","${PASSWORD}","${FIRSTNAMES[@]}","${LASTNAMES[@]}","${TITLE}$","${DEPARTMENT} >> users.csv
done

exit 0

