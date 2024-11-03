#!/bin/bash

clear

echo ""
echo "***************************************************"
echo "**** Yarrow Open-Source Scanner V1.00.011024.A ****"
echo "****                Main Screen                ****"
echo "***************************************************"
echo ""
echo ""
echo "Select search type for open directories"
echo "---------------------------------------"
echo ""
echo "Press 1 for Zip Code"
echo "Press 2 for City Name"
echo "Press 3 for Country code (ISO 3166-1 country code - (US, CN, GB, etc))"
echo "Press 4 to search by Hostname"
echo "Press 5 to scan the complete internet"
read _input
case "$_input" in
    1)
        echo "Enter zip code:"
        read _zip
        ./yarrow_opendirs.sh 1 "$_zip"
        ;;
    2)
        echo "Enter city name:"
        read _city
        ./yarrow_opendirs.sh 2 "$_city"
        ;;
    3)
        echo "Enter country code (ISO 3166-1):"
        read _country
        ./yarrow_opendirs.sh 3 "$_country"
        ;;
    4)
        echo "Enter hostname:"
        read _host
        ./yarrow_opendirs.sh 4 "$_host"
        ;;
    5)
        echo "Launching internet scanner, please wait.."
        sleep 2
        ./yarrow_opendirs.sh 5
        ;;
    *)
        echo "Invalid option selected - "$_input", exiting now."
        ;;
    
esac
