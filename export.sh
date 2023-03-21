#!/bin/bash

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

