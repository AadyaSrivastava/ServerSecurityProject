#!/bin/bash

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

# API Username and Password #
_auth='3d45c090-702c-43da-a3f1-a134f5299907:YCeWVa7FXhZHZVxiYK4JzLVeKHDV4agv'

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

_process=true
_firstrun=true

while [ _process=true ]
do

    _UID=$(date +%s)
    mkdir OUTLOOK_"$_UID"
    ((_recread=_recread+1))
 
    if [ "$_firstrun" = false ] ; then
        # echo IN SECOND RUN
        
          curl -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=services.http.response.body:"$_data"&per_page=1&fields=ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name&cursor=$_next" -o "$_UID"_Outlook_output.txt
          
    fi
    
    if [ "$_firstrun" = true ] ; then
        # echo IN FIRST RUN
    curl -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=services.http.response.body:\"$_data\"&per_page=1&fields=ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name" -o "$_UID"_Outlook_output.txt

        _firstrun=false
    fi
    
    _input=$(cat "$_UID"_Outlook_output.txt)

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
    echo next: $_next

    # Get Ports
    _occurances=$(echo -n $_input | grep -Fo "port" | wc -l)
    # echo _occurances: $_occurances

    for ((i=2; i<=_occurances; i++))
        do
            _out[$i]=$(awk -v _i="$i" -F'port":' '{print $_i}' <<<$_input)
            _out[$i]=${_out[$i]%%\}*}
        
        done

    for ((i=2; i<=_occurances; i++))
        do
            # echo _out[$i]: ${_out[i]}
            _port=$(echo ${_out[i]} | tr -d ' ')
            # echo "curl  -A "$_UA" $_ipadd:$_port -o $_UID_$_port.txt"
            curl  -L -A "$_UA" $_ipadd:$_port -o "$_UID"_Outlook_"$_port".html
        done
    
    mv $_UID* OUTLOOK_"$_UID"
    if [ -z "$_next" ]
    then
        echo "This is the last entry, quitting.."
        _process=false
        exit
    else
        echo Total Records: $_total
        echo Processed: $_recread
        echo "Press any key to read next record.."
        read a
        _process=true
    fi

    

done
