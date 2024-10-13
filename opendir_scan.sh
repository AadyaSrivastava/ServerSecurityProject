#!/bin/bash

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

# API Username and Password #
_auth='3d45c090-702c-43da-a3f1-a134f5299907:YCeWVa7FXhZHZVxiYK4JzLVeKHDV4agv'

# Censys URL #
_baseurl='"https://search.censys.io/api/v2/hosts/search?q='

# Default Header
_basheader='-X 'GET' -H "accept: application/json"'

# Custom fields #
# _custfields='ip,name,services.port,services.tls.certificate.names,services.tls.certificate.parsed.issuer.organization,services.http.request.uri'
_custfields='ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name"'

# Core query #
_query='labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22'

# Results per-page #
_results='1'

# Number of records read #
_recread=0

# Setup Vars
_process=true
_firstrun=true

# Main 
while [ _process=true ]
do

    # Generate UID to store data
    _UID=$(date +%s)
    mkdir "$_UID"

    # Record tracker
    ((_recread=_recread+1))
 
    #Next runs
    if [ "$_firstrun" = false ] ; then
        curl -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22&per_page=1&fields=ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name&cursor=$_next" -o "$_UID"_output.txt
    fi

    # First run
    if [ "$_firstrun" = true ] ; then
        curl -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22&per_page=1&fields=ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name" -o "$_UID"_output.txt

        # So that the code does not come back into this case 
        _firstrun=false
    fi
    
    # Load output in memory
    _input=$(cat "$_UID"_output.txt) 

    # Get total response records
    _rawdata=${_input#*\"total\"\:\ }
    _total=${_rawdata%%\,\ \"*}
    # echo total: $_total
    echo Total Records Found: $_total

    # Parse IP Address from response
    _rawdata=${_input#*\"ip\"\:\ \"}
    _ipadd=${_rawdata%%\"\,*}
    # echo IP: $_ipadd

    # Parse next cursor
    _rawdata=${_input#*\"next\"\:\ \"}
    _next=${_rawdata%%\"\,\ \"*}
    # echo next: $_next

    # Parse number of ports in response
    _occurances=$(echo -n $_input | grep -Fo "port" | wc -l)
    # echo _occurances: $_occurances

    # Concatenate IPs and Ports from responses
    for ((i=2; i<=_occurances; i++))
        do
            _out[$i]=$(awk -v _i="$i" -F'port":' '{print $_i}' <<<$_input)
            _out[$i]=${_out[$i]%%\}*}
        done

    # Get file list from live internet servers as obtained from responses
    for ((i=2; i<=_occurances; i++))
        do
            # echo _out[$i]: ${_out[i]}
            _port=$(echo ${_out[i]} | tr -d ' ')
            # echo "curl  -A "$_UA" $_ipadd:$_port -o $_UID_$_port.txt"
            curl  -L -A "$_UA" $_ipadd:$_port -o "$_UID"_"$_port".txt
        done

    # Move files into the unique folder
    mv $_UID* $_UID
    
    # Check if next next is available
    if [ -z "$_next" ]
    then
        echo "This is the last entry, quitting.."
        _process=false
    else
        echo Total Records: $_total
        echo Processed: $_recread
        # to be removed in production
        echo "Press any key to read next record.."
        read a
        _process=true
    fi
   
done
#end
