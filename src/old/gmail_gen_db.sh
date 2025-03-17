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
# _custfields='ip,name,services.port,services.tls.certificate.names,services.tls.certificate.parsed.issuer.organization,services.http.request.uri'
_custfields='dns.names%2Cwhois.organization.abuse_contacts.email%2Clocation.country_code%2Clocation.city%2Clocation.postal_code%2Clast_updated_at%2Cservices.software.cpe%2Cservices.tls.certificate.names%2Cservices.port%2Cwhois.organization.name'

# Core Query #
_query='services.http.response.html_title%3A%22Google%20Mail%22%20or%20services.http.response.html_title%3A%22Google%20mail%22%20or%20services.http.response.html_title%3A%22google%20mail%22%20or%20services.http.response.html_title%3A%22GMail%22%20or%20services.http.response.html_title%3A%22gmail%22%20or%20services.http.response.html_title%3A%22Gmail%22%20or%20services.http.response.html_title%3A%22google%22%20or%20services.http.response.html_title%3A%22Google%22'


# Results Per Page #
_results='1'

# Number of records read #
_recread=0

_errors=0
_process=true
_firstrun=true

# # check if next exists to resume 
# if [[ -f  next.txt ]]; then
#    _input=$(cat next.txt)

#    #ensure that next value is not NULL
#    if [ -z "$_input" ]; then

#         # this is not a first run
#         _firstrun=false 
        
#         # Get Next Cursor
#         _rawdata=${_input#*\"next\"\:\ \"}
#         _next=${_rawdata%%\"\,\ \"*}
   
#    fi #close for -z $_input
  
# fi # close for -f next.txt

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
       _curlstatus=$(curl --connect-timeout 30 -X 'GET' -H "$_basheader" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&fields=${_custfields}&cursor=$_next" -o Gmail_"$_UID".txt 2>&1) 
        
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
        _curlstatus=$(curl --connect-timeout 30 -X 'GET' -H "$_basheader"  -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&fields=${_custfields}" -o Gmail_"$_UID".txt 2>&1)
        
        #log failure
        if [ $? -ne 0 ] ; then
            _ctime=$(date '+%d-%m-%Y_%H:%M:%S')
            ((_errors=_errors+1))
            echo "$_ctime", "$_recread", "$_next", "$_query" >> "$_DIRUID"_error_log.txt 
        
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
