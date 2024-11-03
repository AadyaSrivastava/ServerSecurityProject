#!/bin/bash
clear

# Set output folder name #
_DIRUID=$(date '+%d_%m_%Y_%H_%M_%S')
mkdir OPENDIRS_"$_DIRUID"

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

# API Username and Password #
_auth='user:pass'

# Censys URL #
_baseurl='"https://search.censys.io/api/v2/hosts/search?q='

# Default Headerss
_basheader='-X 'GET' -H "accept: application/json"'


# Encode input #
_inp2="$2"
 _qcase=$(echo "$_inp2" | sed \
        -e 's/%/%25/g' -e 's/ /%20/g' \
        -e 's/!/%21/g' -e 's/"/%22/g' \
        -e "s/'/%27/g" -e 's/#/%23/g' \
        -e 's/(/%28/g' -e 's/)/%29/g' \
        -e 's/+/%2b/g' -e 's/,/%2c/g' \
        -e 's/-/%2d/g' -e 's/:/%3a/g' \
        -e 's/;/%3b/g' -e 's/?/%3f/g' \
        -e 's/@/%40/g' -e 's/\$/%24/g' \
        -e 's/\&/%26/g' -e 's/\*/%2a/g' \
        -e 's/\./%2e/g' -e 's/\//%2f/g' \
        -e 's/\[/%5b/g' -e 's/\\/%5c/g' \
        -e 's/\]/%5d/g' -e 's/\^/%5e/g' \
        -e 's/_/%5f/g' -e 's/`/%60/g' \
        -e 's/{/%7b/g' -e 's/|/%7c/g' \
        -e 's/}/%7d/g' -e 's/~/%7e/g')


case "$1" in
    1)
        _query="labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22%20and%20location.postal_code%3A$_qcase"
        _title="AUDIT REPORT FOR POST CODE: $_qcase"
        ;;
    2)
        _query="labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22%20and%20location.city%3A$_qcase"
        _title="AUDIT REPORT FOR CITY: $_qcase"
        ;;
    3)
        _query="labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22%20and%20location.country_code%3A$_qcase"
        _title="AUDIT REPORT FOR COUNTRY CODE: $_qcase"
        ;;
    4)
        _query="labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22%20and%20name%3A$_qcase"
        _title="AUDIT REPORT FOR HOSTNAME: $_qcase"
        ;;
    5)
        _query="labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22"
        _title="AUDIT REPORT FOR THE COMPLETE INTERNET"
        ;;
    *)
        echo Exiting. Error code: ERRC1
        exit
esac

# Fields #
_fields='ip%2Cservices.port%2Clocation.city%2Clocation.country%2Cwhois.organization.abuse_contacts.email%2Cservices.tls.certificate.names'

# Results Per Page #
_results='1'

# Number of records read #
_recread=0

_errors=0
_process=true
_firstrun=true

echo "<html>" > Output_Feed_"$_DIRUID".html
echo "<body>" >> Output_Feed_"$_DIRUID".html
echo "<br><b>OPEN DIRECTOR SERVER LIST</b><br>" >> Output_Feed_"$_DIRUID".html
echo "<br><b>$_title</b><br><br>" >> Output_Feed_"$_DIRUID".html
echo "<b>Day_Time,Country,City,IP:Port,URL,Raw_Response,Remote_Server</b><br>" >> Output_Feed_"$_DIRUID".html
echo "<html>" > Error_Feed_"$_DIRUID".html
echo "<body>" >> Error_Feed_"$_DIRUID".html
echo "<b>Day_Time,Country,City,IP:Port,URL</b><br>" >> Error_Feed_"$_DIRUID".html
while [ _process=true ]
do

    #Unique ID
    _UID=$(date '+%d%m%Y%H%M%S')
   
    if [ "$_firstrun" = false ] ; then
        
        # Next Run query for Censys
        curl -s -m 30 -X 'GET' -H "$_basheader" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&virtual_hosts=EXCLUDE&sort=RELEVANCE&fields=${_fields}&cursor=$_next" -o "$_UID"_output.txt
    
    fi
    
    if [ "$_firstrun" = true ] ; then
        
        # First run query for Censys
        curl -s -m 30 -X 'GET' -H "$_basheader" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&virtual_hosts=EXCLUDE&sort=RELEVANCE&fields=${_fields}" -o "$_UID"_output.txt
        
        _firstrun=false
       
    fi
    

    # load output in memory #
    _input=$(cat "$_UID"_output.txt)
    
    # Get Mactched Services Element #
    _melementraw=${_input#*\"matched_services\"\:\ }
    _melement=${_melementraw%%\"links\"\:*}

    # Get Total #
    _rawdata=${_input#*\"total\"\:\ }
    _total=${_rawdata%%\,\ \"*}

    # Get IP Address
    _rawdata=${_input#*\"ip\"\:\ \"}
    _ipadd=${_rawdata%%\"\,*}

    # Get City
    _rawdata=${_input#*\"city\"\:\ \"}
    _city=${_rawdata%%\"\,*}

    # Get Country
    _rawdata=${_input#*\"country\"\:\ \"}
    _country=${_rawdata%%\"\}*}

    #  # Get Abuse Contact email
    # _rawdata=${_input#*\"email\"\:\ \"}
    # _abusect=${_rawdata%%\"\,*}

    # Get Next Cursor
    _rawdata=${_input#*\"next\"\:\ \"}
    _next=${_rawdata%%\"\,\ \"*}
 
    # Get Ports
    _occurances=$(echo -n $_melement | grep -Fo '"port":' | wc -l)
    # echo port occurs: $_occurances

      # Get port numbers in response and load them in an array #
    for ((i=2; i<=_occurances+1; i++))
    do
        _out[$i]=$(awk -v _i="$i" -F'\"port\"\:' '{print $_i}' <<<$_melement)
        # echo 1_out[$i]: ${_out[$i]}
        _portraw=${_out[$i]#*\"port\"\:\ }
        _out[$i]=${_portraw%%\}*} 
        # echo _out[$i]: ${_out[$i]}
    done

   
    # echo _total: $_total 
    # echo _ipadd: $_ipadd 
    # echo city: $_city 
    # echo Country: $_country 
    # exit

    # Generate Feed #
    for ((i=2; i<=_occurances+1; i++))
    do  
       
        # Parse port and get file listing from remote server #
        _port=$(echo ${_out[$i]} | tr -d ' ')

        # generate temorary filename #
        _cfname=$(echo "$_UID"_"$_ipadd"_"$_port".txt)

        # Get file-list from live server #
        if [[ "$_port" == "443" ]]; then 
            _curlstatus=$(curl -K -m 30 -L -A "$_UA" https://"$_ipadd":"$_port" -o "$_cfname"  2>&1)
            #curl -m 30 -k -L -A "$_UA" https://"$_ipadd":"$_port" -o "$_cfname"
        else
            _curlstatus=$(curl -m 30 -L -A "$_UA" http://"$_ipadd":"$_port" -o "$_cfname"  2>&1)
            #curl -m 30 -L -A "$_UA" http://"$_ipadd":"$_port" -o "$_cfname" 
        fi

        if [ $? -ne 0 ] ; then
            ((_errors=_errors+1))
            
            # Uncomment line below to view server error code
            #echo curlstat: $?
            
            echo "Error when connecting with "$_ipadd":"$_port" at "$_ctime""
            echo "Error logged in file Error_Feed_"$_DIRUID".html"
            echo "$_ctime,$_country,$_city,<a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Error_Feed_"$_DIRUID".html
            
        else
            ((_recread=_recread+1))
            
            # Perform local scan to check if output file has .exe in response #
            _lscan=$(cat "$_cfname" | grep .exe)

            # Get size of reply in
            _sz=$(wc -w <<< "$_lscan")

            if [[ $_sz -gt 0 ]]; then 

                # Executable located in response #
                mv "$_cfname" OPENDIRS_"$_DIRUID"
                
                _ctime=$(date '+%d-%m-%Y_%H:%M:%S')
                
                # Save file lists in feed for production #
                if [[ "$_port" == "443" ]]; then 
                    echo "$_ctime,$_country,$_city,$_ipadd:$_port,<a href=./OPENDIRS_$_DIRUID/$_cfname target="_blank" rel="noopener noreferrer">$_cfname</a>,<a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Output_Feed_"$_DIRUID".html
                else
                    echo "$_ctime,$_country,$_city,$_ipadd:$_port,<a href=./OPENDIRS_$_DIRUID/$_cfname target="_blank" rel="noopener noreferrer">$_cfname</a>,<a href=http://$_ipadd:$_port target="_blank" rel="noopener noreferrer">http://$_ipadd:$_port</a><br>" >> Output_Feed_"$_DIRUID".html
                
                fi

                

                # Remove working file #
                rm -rf "$_cfname"
            else
                
                # Remove working file #
                rm -rf "$_cfname"
            
            fi # end of if [[ $_sz -gt 0 ]]; then 
        
        fi # end of if [ $? -ne 0 ] ; then

    done # end of for ((i=0; i<_occurances; i++))

    # move Censys response to storage folder #
    mv "$_UID"_output.txt OPENDIRS_"$_DIRUID"
    
    if [ -z "$_next" ]
    then
        echo "This is the last entry, quitting.."
        
        echo "<br><b>Total Records Found:</b>" $_total >> Output_Feed_"$_DIRUID".html
        echo "<br><b>Servers accessible:</b> $_recread<br>">> Output_Feed_"$_DIRUID".html

        # Close HTML file tags #
        echo "</body>" >> Output_Feed_"$_DIRUID".html
        echo "</html>" >> Output_Feed_"$_DIRUID".html
        echo "</body>" >> Error_Feed_"$_DIRUID".html
        echo "</html>" >> Error_Feed_"$_DIRUID".html
        
        # Exit while loop #
        _process=false
        exit
    else
        echo "Open directory found: $_ipadd:$_port located in $_city, $_country"
        echo Processed: "$_recread"  Errors: "$_errors"  Total Records: "$_total"
        
        # Wait for user to press a key to process next record #
        # Two lines below may be commented to automate #
        # echo "Press any key to read next record.."
        # read a
        _process=true
    fi

done #end of while [ _process=true ]
