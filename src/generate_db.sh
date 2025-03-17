#!/bin/bash

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

# API Username and Password #
_auth='user:pass'

# Censys URL #
_baseurl='"https://search.censys.io/api/v2/hosts/search?q='

# Default Header
_basheader='-X 'GET' -H "accept: application/json"'

# Custom Fields #
_custfields='ip,dns.names%2Cwhois.organization.abuse_contacts.email%2Clocation.country_code%2Clocation.city%2Clocation.postal_code%2Clast_updated_at%2Cservices.software.cpe%2Cservices.tls.certificate.names%2Cservices.port%2Cwhois.organization.name%2Cautonomous_system.asn%2Cautonomous_system.name%2Cautonomous_system.bgp_prefix%2Cservices.tls.certificate.parsed.issuer_dn%2Cservices.tls.certificate.parsed.serial_number%2Cservices.tls.certificate.parsed.signature.self_signed%2Cautonomous_system.bgp_prefix%2Cdns.reverse_dns.names'

# Core Query #
_query='services.http.response.html_title%3Agmail%20or%20services.http.response.body%3A%22to%20continue%20to%20Gmail%22'

# Results Per Page #
_results='1'

# Number of records read #
_recread=0
_errors=0
_process=true
_firstrun=true

# Set output folder name #
_DIRUID=$(date '+%d_%m_%Y_%H_%M_%S')
mkdir Gmail_"$_DIRUID"
mkdir Gmail_"$_DIRUID"/sourcedata
mkdir Gmail_"$_DIRUID"/ignored
  
# get datasets from Censys
while [[ "$_process" == "true" ]]
do

    # gen unique ID for each record
    _UID=$(date '+%d_%m_%Y_%H_%M_%S')
   
    ((_recread=_recread+1))
 
    if [ "$_firstrun" = false ] ; then
        #echo IN SECOND RUN
       _curlstatus=$(curl --connect-timeout 30 -X 'GET' -H "$_basheader" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&virtual_hosts=INCLUDE&fields=${_custfields}&cursor=$_next" -o Gmail_"$_UID".txt 2>&1) 
        
        #log failure
        if [ $? -ne 0 ] ; then
            _ctime=$(date '+%d-%m-%Y_%H:%M:%S')
            ((_errors=_errors+1))
            echo "$_ctime", "$_recread", "$_next", "$_query" >> "$_DIRUID"_error_log.txt 
        fi
    fi
    
    if [ "$_firstrun" = true ] ; then
        #echo IN FIRST RUN
        _firstrun=false
        _curlstatus=$(curl --connect-timeout 30 -X 'GET' -H "$_basheader"  -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&virtual_hosts=INCLUDE&fields=${_custfields}" -o Gmail_"$_UID".txt 2>&1)
        
        #log failure
        if [ $? -ne 0 ] ; then
            _ctime=$(date '+%d-%m-%Y_%H:%M:%S')
            ((_errors=_errors+1))
            echo "$_ctime", "$_recread", "$_next", "$_query" >> "$_DIRUID"_error_log.txt 
            echo "Error on first query, exiting.."
            exit
        else #success
            _input=$(cat Gmail_"$_UID".txt)
            
            #Get Total Count
            _rawdata=${_input#*\"total\"\:\ }
            _total=${_rawdata%%\,\ \"*}
        fi
    fi  
    
    #SLEEP 
    sleep 2

    _input=$(cat Gmail_"$_UID".txt)
    
    # Get Next Cursor
    _rawdata=${_input#*\"next\"\:\ \"}
    _next=${_rawdata%%\"\,\ \"*}

    echo $_next > next.txt
    
    # move Censys response to storage folder #
    mv Gmail_"$_UID".txt Gmail_"$_DIRUID"/sourcedata

    # check if next cursor exists
    if [ -z "$_next" ]
    then
        # is it a curl failure
        if [[ $_recread -lt $_total ]]; then
            _ctime=$(date '+%d-%m-%Y_%H:%M:%S')
            ((_errors=_errors+1))
            echo "$_ctime", "$_recread", "$_next", "$_query" >> "$_DIRUID"_error_log.txt 
            echo Processed: "$_recread"  Errors: "$_errors"  Total Records: "$_total"
            rm next.txt
            _process=true
        else
            echo "This is the last entry, quitting.."
            rm next.txt
            mv "$_DIRUID"_error_log.txt Gmail_"$_DIRUID"/sourcedata
            # Exit while loop #
            _process=false
            exit # added as sometimes next is not null but the data responses have reached a limit. To be optimised.
        fi
    else
        echo Processed: "$_recread"  Errors: "$_errors"  Total Records: "$_total"
        rm next.txt
        _process=true
    fi #if [ -z "$_next" ]
    

done #end of while [ _process=true ]
