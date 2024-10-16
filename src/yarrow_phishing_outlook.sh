#!/bin/bash

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

# API Username and Password #
_auth='USER:PASS'

# Censys URL #
_baseurl='"https://search.censys.io/api/v2/hosts/search?q='

# Default Header
_basheader='-X 'GET' -H "accept: application/json"'

# Custom Fields #
# _custfields='ip,name,services.port,services.tls.certificate.names,services.tls.certificate.parsed.issuer.organization,services.http.request.uri'
_custfields='ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name"'

# Core Query #
_data=$(cat RSD/outlook_rules.rsd)
# _query=labels:open-dir%20and%20services.http.response.body:%20\".exe\"
_query='services.http.response.body%3A$_data'

# Results Per Page #
_results='1'

# Number of records read #
_recread=0

_errors=0
_process=true
_firstrun=true

# Set output folder name #
_DIRUID=$(date '+%d_%m_%Y_%H_%M_%S')
mkdir OUTLOOK_"$_DIRUID"


while [ _process=true ]
do

    _UID=$(date '+%d_%m_%Y_%H_%M_%S')
   
    ((_recread=_recread+1))
 
    if [ "$_firstrun" = false ] ; then
        echo IN SECOND RUN
        curl -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=services.http.response.body:\"$_data\"&per_page=1&fields=ip%2Cservices.port&cursor=$_next" -o Outlook_"$_UID".txt
        # _input=$(cat Outlook_"$_UID".txt)
       
    fi
    
    if [ "$_firstrun" = true ] ; then
        echo IN FIRST RUN
        curl -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=services.http.response.body:\"$_data\"&per_page=1&fields=ip%2Cservices.port" -o Outlook_"$_UID".txt
        _firstrun=false
    fi
    

    _input=$(cat Outlook_"$_UID".txt)
    # _input=$(cat 1729086323_Outlook_output.txt)

    # Get Mactched Services Element #
    _melementraw=${_input#*\"matched_services\"\:\ }
    _melement=${_melementraw%%\"links\"\:*}
    # echo _melement: $_melement
    # Get Total
    _rawdata=${_input#*\"total\"\:\ }
    _total=${_rawdata%%\,\ \"*}
    # echo total: $_total
    echo Total Records Found: $_total

    # Get IP Address
    _rawdata=${_input#*\"ip\"\:\ \"}
    _ipadd=${_rawdata%%\"\,*}
    # echo IP: $_ipadd

    # Get Next Cursor
    _rawdata=${_input#*\"next\"\:\ \"}
    _next=${_rawdata%%\"\,\ \"*}
    # echo next: $_next

    # Get occurances of ports in response
    _occurances=$(echo -n $_melement | grep -Fo '"port":' | wc -l)
    echo _occurances: $_occurances

    # Get port numbers in response and load them in an array #
    for ((i=2; i<=_occurances+1; i++))
    do
        _out[$i]=$(awk -v _i="$i" -F'\"port\"\:' '{print $_i}' <<<$_melement)
        # echo 1_out[$i]: ${_out[$i]}
        _portraw=${_out[$i]#*\"port\"\:\ }
        _out[$i]=${_portraw%%\}*} 
        echo _out[$i]: ${_out[$i]}
    done
    
    # Generate Feed #
    for ((i=2; i<_occurances+1; i++))
    do
        # Parse port and get file listing from remote server #
        _port=$(echo ${_out[$i]} | tr -d ' ')

        # generate temorary filename #
        _cfname=$(echo Outlook_"$_UID"-"$_ipadd"-"$_port".html)

        # Get suspected phishing page from live server #
        if [[ "$_port" == "443" ]]; then 
            _curlstatus=$(curl -m 30 -L -A "$_UA" https://"$_ipadd":"$_port" -o "$_cfname"  2>&1)
        else
            _curlstatus=$(curl -m 30 -L -A "$_UA" http://"$_ipadd":"$_port" -o "$_cfname"  2>&1)
        fi
  
        if [ $? -ne 0 ] ; then
            ((_errors=_errors+1))
            echo " " 
            echo "Error when connecting with "$_ipadd":"$_port" at "$_ctime""
            echo "Error logged in file connect_error.txt"
            echo "--------------------------------------"
            echo Censys Respose: "$_UID"_output.txt >> connect_error.txt
            echo Query Details: "$_ctime" "$_ipadd":"$_port" >> connect_error.txt
            echo Query Response: >> connect_error.txt
            echo " " >> connect_error.txt
            echo "$_curlstatus" >> connect_error.txt
            echo " " >> connect_error.txt
            echo "---------------------------" >> connect_error.txt
            echo " " >> connect_error.txt
            echo " " >> connect_error.txt
            echo " " >> connect_error.txt
                
        else

            
            mv "$_cfname" OUTLOOK_"$_DIRUID"
            
            _ctime=$(date '+%d:%m:%Y %H:%M:%S')
            
            # Save file lists in feed for production #
            if [[ "$_port" == "443" ]]; then 
                echo $_ctime "$_ipadd":"$_port" https:\/\/"$_ipadd":"$_port" "$_cfname" "$_UID"_output.txt >> "$_DIRUID"_feed_outlook.txt
            else
                echo $_ctime "$_ipadd":"$_port" http:\/\/"$_ipadd":"$_port" "$_cfname" "$_UID"_output.txt >> "$_DIRUID"_feed_outlook.txt
            
            fi
            
            # Remove file #
            rm -rf "$_cfname"
        
        fi # end of if [ $? -ne 0 ] ; then

    done # end of for ((i=0; i<_occurances; i++))

    # move Censys response to storage folder #
    mv Outlook_"$_UID".txt OUTLOOK_"$_DIRUID"

    if [ -z "$_next" ]
    then
        echo "This is the last entry, quitting.."
        
        # Exit while loop #
        _process=false
        exit
    else
        echo Processed: "$_recread"  Errors: "$_errors"  Total Records: "$_total"
    
        # Wait for user to press a key to process next record #
        # Two lines below may be commented to automate #
        # echo "Press any key to read next record.."
        # read a
        _process=true
    fi
    

done #end of while [ _process=true ]
