#!/bin/bash

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

# API Username and Password #
_auth='Username:Password'

# Censys URL #
_baseurl='"https://search.censys.io/api/v2/hosts/search?q='

# Default Header
_basheader='-X 'GET' -H "accept: application/json"'

# Custom Fields #
# _custfields='ip,name,services.port,services.tls.certificate.names,services.tls.certificate.parsed.issuer.organization,services.http.request.uri'
_custfields='ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name"'

# Core Query #
# _query=labels:open-dir%20and%20services.http.response.body:%20\".exe\"
_query='labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22'

# Results Per Page #
_results='1'

# Number of records read #
_recread=0

_process=true
_firstrun=true

# Set output folder name #
_DIRUID=$(date '+%d_%m_%Y_%H_%M_%S')
mkdir OPENDIRS_"$_DIRUID"

while [ _process=true ]
do

    _UID=$(date '+%d_%m_%Y_%H_%M_%S')
    # mkdir OPENDIRS_"$_DIRUID"
    ((_recread=_recread+1))
 
    if [ "$_firstrun" = false ] ; then
        
        # Next Run query for Censys
        curl -s -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22&per_page=1&fields=ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name&cursor=$_next" -o "$_UID"_output.txt
    
    fi
    
    if [ "$_firstrun" = true ] ; then
        
        # First run query for Censys
        curl -s -X 'GET' -H "accept: application/json" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22&per_page=1&fields=ip%2Cname%2Cservices.port%2Cservices.tls.certificate.names%2Cservices.tls.certificate.parsed.issuer.organization%2Cservices.dns.answers.name" -o "$_UID"_output.txt

        _firstrun=false
    fi
    

    # load output in memory #
    _input=$(cat "$_UID"_output.txt)

    # Get Total #
    _rawdata=${_input#*\"total\"\:\ }
    _total=${_rawdata%%\,\ \"*}
    echo Total Records Found: $_total

    # Get IP Address
    _rawdata=${_input#*\"ip\"\:\ \"}
    _ipadd=${_rawdata%%\"\,*}

    # Get Next Cursor
    _rawdata=${_input#*\"next\"\:\ \"}
    _next=${_rawdata%%\"\,\ \"*}

    # Get Ports
    _occurances=$(echo -n $_input | grep -Fo "port" | wc -l)

    # Get port numbers in response and load them in an array #
    for ((i=2; i<=_occurances; i++))
        do
            _out[$i]=$(awk -v _i="$i" -F'port":' '{print $_i}' <<<$_input)
            _out[$i]=${_out[$i]%%\}*}
        done
   
    # Generate Feed #
    for ((i=2; i<=_occurances; i++))
        do
    
            # Parse port and get file listing from remote server #
            _port=$(echo ${_out[i]} | tr -d ' ')
            
            # generate temorary filename #
            _cfname=$(echo "$_UID"-"$_ipadd"-"$_port".txt)

            curl -s --connect-timeout 20 -L -A "$_UA" $_ipadd:$_port -o "$_cfname"

            # Perform local scan to check if output file has .exe in response #
            _lscan=$(cat "$_cfname" | grep .exe)

            # Get size of reply in
            _sz=$(wc -w <<< "$_lscan")

            if [[ $_sz -gt 0 ]]; then 

                # Executable located in response #
                mv "$_cfname" OPENDIRS_"$_DIRUID"
                
                _ctime=$(date '+%d:%m:%Y %H:%M:%S')

                # Save file lists in feed for production #
                if [[ "$_port" == "443" ]]; then 
                    echo $_ctime "$_ipadd":"$_port" https:\/\/"$_ipadd":"$_port" >> "$_UID"_feed_opendirs.txt
                else
                    echo $_ctime "$_ipadd":"$_port" http:\/\/"$_ipadd":"$_port" >> "$_UID"_feed_opendirs.txt
                
                fi
                
                # Remove file #
                rm -rf "$_cfname"
            else
                
                # Remove file #
                rm -rf "$_cfname"
            fi


        done
    
    # move Censys response to storage folder #
    mv "$_UID"_output.txt OPENDIRS_"$_DIRUID"
    
    if [ -z "$_next" ]
    then
        echo "This is the last entry, quitting.."
        
        # Exit while loop #
        _process=false
    else
        echo Total Records: $_total
        echo Processed: $_recread
       
        # Wait for user to press a key to process next record #
        # Two lines below may be commented to automate #
        echo "Press any key to read next record.."
        read a
        _process=true
    fi
    

done
