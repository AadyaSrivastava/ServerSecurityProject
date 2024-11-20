#!/bin/bash

clear

_malwaremodule='module1.sh'
_documentemodule='module2.sh'

echo ""
echo "***************************************************"
echo "****   SSP Open-Source Scanner V1.00.011024.A  ****"
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
echo "Press 5 to scan the Internet"
# echo "Press 6 to scan the Internet"
read _input
case "$_input" in
    1)
        echo "Enter zip code:"
        read _zip
        ./$_malwaremodule 1 "$_zip"
        # echo "Malware Module completed. Press any key to start scanning for document leaks.."
        # read a
        ./$_documentemodule 2 "$_zip"
        ;;
    2)
        echo "Enter city name:"
        read _city
        ./$_malwaremodule 2 "$_city"
        # echo "Malware Module completed. Press any key to start scanning for document leaks.."
        # read a
        ./$_documentemodule 2 "$_city"
        ;;
    3)
        echo "Enter country code (ISO 3166-1):"
        read _country
        ./$_malwaremodule 3 "$_country"
#         echo "Malware Module completed. Press any key to start scanning for document leaks.."
#         read a
        ./$_documentemodule 2 "$_country"
        ;;
    4)
        echo "Enter DNS Name (www.domain.com) or TDL (*.domain.com):"
        read _host
        ./$_malwaremodule 4 "$_host"
        # echo "Malware Module completed. Press any key to start scanning for document leaks.."
        # read a
        ./$_documentemodule 2 "$_host"
        ;;
    5)
    #     echo "Enter IP Range eg: [1.12.0.0 to 1.15.255.255]"
    #     read _iprange
    #     ./$_malwaremodule 5 "$_iprange"
    #     ;;
    
    # 6)
        echo "Scan the Complete Internet"
        sleep 2
        ./$_malwaremodule 5
        # echo "Malware Module completed. Press any key to start scanning for document leaks.."
        # read a
        ./$_documentemodule 5
        ;;

    *)
        echo "Invalid option selected - "$_input", exiting now."
        ;;
  
esac
