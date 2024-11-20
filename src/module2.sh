#!/bin/bash
clear

# Set output folder name #
_DIRUID=$(date '+%d_%m_%Y_%H_%M_%S')
mkdir OPENDIRS_"$_DIRUID"

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

# API Username and Password #
_auth='3d45c090-702c-43da-a3f1-a134f5299907:YCeWVa7FXhZHZVxiYK4JzLVeKHDV4agv'

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
        -e 's/\[/%5b/g' -e 's/\\/%5c/g' \
        -e 's/\]/%5d/g' -e 's/\^/%5e/g' \
        -e 's/_/%5f/g' -e 's/`/%60/g' \
        -e 's/{/%7b/g' -e 's/|/%7c/g' \
        -e 's/\./%2e/g' -e 's/\//%2f/g' \
        -e 's/}/%7d/g' -e 's/~/%7e/g')

#-e 's/\./%2e/g' -e 's/\//%2f/g' \
# ip%3A%5B1.12.0.0%20to%201.15.255.255%5D%
#      %5b1.12.0.0%20to%201.15.255.255%5d
#and ip:[1.12.0.0 to 1.15.255.255] 
case "$1" in
    1)
        _query="labels%3Aopen-dir%20and%20%28services.http.response.body%3A%22doc%22%20or%20services.http.response.body%3A%22docx%22%20or%20services.http.response.body%3A%22.txt%22%29%20and%20location.postal_code%3A$_qcase"
        _title="FILE LEAK AUDIT REPORT FOR POST CODE: $_qcase"
        ;;
    2)
        _query="labels%3Aopen-dir%20and%20%28services.http.response.body%3A%22doc%22%20or%20services.http.response.body%3A%22docx%22%20or%20services.http.response.body%3A%22.txt%22%29%20and%20location.city%3A$_qcase"
        _title="FILE LEAK AUDIT REPORT FOR CITY: $_qcase"
        ;;
    3)
        # labels%3Aopen-dir%20and%20%28services.http.response.body%3A%22.dmg%22%20or%20services.http.response.body%3A%22.exe%22%29
        _query="labels%3Aopen-dir%20and%20%28services.http.response.body%3A%22doc%22%20or%20services.http.response.body%3A%22docx%22%20or%20services.http.response.body%3A%22.txt%22%29%20and%20location.country_code%3A$_qcase"
        # _query="labels%3Aopen-dir%20and%20services.http.response.body%3A%20%22.exe%22%20and%20location.country_code%3A$_qcase"
        _title="FILE LEAK AUDIT REPORT FOR COUNTRY CODE: $_qcase"
        ;;
    4)
        _query="labels%3Aopen-dir%20and%20%28services.http.response.body%3A%22doc%22%20or%20services.http.response.body%3A%22docx%22%20or%20services.http.response.body%3A%22.txt%22%29%20and%20dns.names%3A%22$_qcase%22"
        _title="FILE LEAK AUDIT REPORT FOR HOSTNAME: $_qcase"
        ;;
    5)
    #     echo "$_qcase"
    #     # exit
    #     _query="labels%3Aopen-dir%20and%20%28services.http.response.body%3A%22.dmg%22%20or%20services.http.response.body%3A%22.exe%22%29and%20ip%3A$_qcase"
    #      _title="OPEN DIRECTORY AUDIT REPORT FOR IP RANGE: $_qcase"
    #     ;;
    # 6)
        _query="labels%3Aopen-dir%20and%20%28services.http.response.body%3A%22doc%22%20or%20services.http.response.body%3A%22docx%22%20or%20services.http.response.body%3A%22.txt%22%29%"
        _title="FILE LEAK AUDIT REPORT FOR THE COMPLETE INTERNET"
        ;;
        
    *)
        echo Exiting. Error code: ERRC1
        exit
esac

# Fields #
_fields='ip%2Cservices.port%2Cdns.names%2Clocation.city%2Clocation.country%2Cwhois.organization.abuse_contacts.email%2Cwhois.organization.tech_contacts.email%2Cwhois.organization.admin_contacts.email%2Cservices.tls.certificate.names%2Coperating_system.cpe%2Cservices.software.cpe%2Clast_updated_at'

# Results Per Page #
_results='1'

# Number of records read #
_recread=0

_errors=0
_process=true
_firstrun=true

echo "<html>" > Out_Files_Feed_"$_DIRUID".html
echo "<head>" >> Out_Files_Feed_"$_DIRUID".html
echo "<title>Response Feed: $_title</title>" >> Out_Files_Feed_"$_DIRUID".html
echo "</head>" >> Out_Files_Feed_"$_DIRUID".html
echo "<body>" >> Out_Files_Feed_"$_DIRUID".html
echo "<br><h1><b>$_title</b></h1><br>" >> Out_Files_Feed_"$_DIRUID".html
echo "<html>" > OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html
echo "<head>" >> Out_Files_Feed_"$_DIRUID".html
echo "<title>Error Feed: $_title</title>" >> Out_Files_Feed_"$_DIRUID".html
echo "</head>" >> Out_Files_Feed_"$_DIRUID".html
echo "<body>" >> OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html
echo "<br><h1><b>Error Logs</b></h1><br>" >> OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html
echo "<b>Day_Time,Country,City,IP:Port,URL</b><br>" >> OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html
while [ _process=true ]
do

    #Unique ID
    _UID=$(date '+%d%m%Y%H%M%S')
   
    if [ "$_firstrun" = false ] ; then
        
        # Next Run query for Censys
        curl -s -m 30 -X 'GET' -H "$_basheader" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&fields=${_fields}&cursor=$_next" -o "$_UID"_output.txt
    
    fi
    
    if [ "$_firstrun" = true ] ; then
        
        # First run query for Censys
        curl -s -m 30 -X 'GET' -H "$_basheader" -A "$_UA" -u "$_auth" "https://search.censys.io/api/v2/hosts/search?q=${_query}&per_page=1&fields=${_fields}" -o "$_UID"_output.txt
        
        _firstrun=false
       
    fi
    

    # load output in memory #
    _input=$(cat "$_UID"_output.txt)
    
    # Last updated #
    _rawdata=${_input#*\"last_updated_at\"\:\ \"}
    _lupdate=${_rawdata%%Z\"\,\ *}

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

     # Get Abuse Contact email
    _rawdata=${_input#*\"email\"\:\ \"}
    _abusect=${_rawdata%%\"\,*}

    # Get Next Cursor
    _rawdata=${_input#*\"next\"\:\ \"}
    _next=${_rawdata%%\"\,\ \"*}
 
    # Get Ports
    _occurances=$(echo -n $_melement | grep -Fo '"port":' | wc -l)
    # echo port occurs: $_occurances

    # Get Emails
    # _tput=$(whois $_ipadd | grep e-mail | awk -F: '{print $2}') 
    # echo "$(sed -e 's/^[[:space:]]*//'<<<"${_tput}")" | awk -F" " '{print $1}' > email.txt
    # #whois $_ipadd | grep e-mail | awk -F: '{print $2}' | tr -d " "> email.txt
    
    # Get Abuse Emails
    # _tput=$(whois $_ipadd | grep abuse | awk -F: '{print $2}' )
    # echo "$(sed -e 's/^[[:space:]]*//'<<<"${_tput}")" | awk -F" " '{print $1}' > abuse.txt
    # #whois $_ipadd | grep abuse | awk -F: '{print $2}' | tr -d " "> abuse.txt
    
    #Whois Data
    curl -s https://rdap.apnic.net/ip/$_ipadd > email.txt
    _tput=$(grep -E -o '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}' email.txt)
    echo "$(sed -e 's/^[[:space:]]*//'<<<"${_tput}")" | awk -F" " '{print $1}' > abuse.txt
    

    # Get port numbers in response and load them in an array #
    for ((i=2; i<=_occurances+1; i++))
    do
        _out[$i]=$(awk -v _i="$i" -F'\"port\"\:' '{print $_i}' <<<$_melement)
        # echo 1_out[$i]: ${_out[$i]}
        _portraw=${_out[$i]#*\"port\"\:\ }
        _out[$i]=${_portraw%%\}*} 
        # echo _out[$i]: ${_out[$i]}
    done

    # Get OS cpe #
    _rawdata=${_input#*\"operating_system\"\:\ \{\"cpe\"\:\ \"}
    # Calculate the length of response    
    _rdatares=$(echo $_input | grep operating_system)
    _replylen=${#_rdatares}

    if [ $_replylen -le 2 ]; then
        _oscpe='Not found'
    else
        _oscpe=$(echo $_rawdata | awk -F\} '{print $1}' | tr -d "\"")
    fi
    

    # # Get DNS names #
    # _rawdata=${_input#*\"dns\"\:\ \{\"names\"\:\ \[}
    # _dnsnames=${_rawdata%%\]\}\,*}

    # Get DNS names #
    # _rawdata=${_input#*\"dns\"\:}
    # _dnsnamesraw=${_rawdata%%\"\]\}\, \"location*}
    _rawdata=${_input#*\"names\":\ \[}
    _dnsnamesraw=$(echo $_rawdata | awk -F] '{print $1}')
    _dnsnames=$(echo $_dnsnamesraw | tr -d \" | tr -d { | tr -d } | tr -d ] | tr -d \[) 

    # Calculate the length of response    
    _dnsstrlen=${#_dnsnames}

    if [ $_dnsstrlen -le 2 ]; then
        _dnsnames='Not found'
    fi

    # Get software count
    _soccurances=$(echo -n $_input | grep -Fo '{"software":' | wc -l)

    _ctime=$(date '+%d-%m-%Y_%H:%M:%S')

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
            _live=false
            # Uncomment line below to view server error code
            #echo curlstat: $?
            
            echo "Error when connecting with "$_ipadd":"$_port" at "$_ctime""
            echo "Error logged in file OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html"
            echo "$_ctime,$_country,$_city,<a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html
            
        else
            
            _live=true
            # Valid reply found #
            ((_recread=_recread+1))
        
        fi
            # Perform local scan to check if output file has .exe in response #
            # _lscan=$(cat "$_cfname" | grep .exe)

            # Get size of reply in
            # _sz=$(wc -w <<< "$_lscan")

            # if [[ $_sz -gt 0 ]]; then 

                

                # Executable located in response #
                mv "$_cfname" OPENDIRS_"$_DIRUID"
                
                
                
                # Save file lists in feed for production #
                echo "<br><b>Server IP:</b> $_ipadd" >> Out_Files_Feed_"$_DIRUID".html
                echo "<br><b>Server Port:</b> $_port" >> Out_Files_Feed_"$_DIRUID".html
                echo "<br><b>Server Location:</b> $_city, $_country" >> Out_Files_Feed_"$_DIRUID".html
                
                echo "<br><b>DNS Name:</b> $_dnsnames" >> Out_Files_Feed_"$_DIRUID".html
                echo "<br><b>Server OS:</b> $_oscpe" >> Out_Files_Feed_"$_DIRUID".html
                    
                echo "<br><br><u>Server port and software info:</u><br>" >> Out_Files_Feed_"$_DIRUID".html                 
                # Get software-cpe combo and load them in an array #
                for ((i=2; i<=_soccurances+1; i++))
                do
                    if [ $i -gt $_soccurances ]; then
                        
                        _sout[$i]=$(awk -v _i="$i" -F'\{\"software\"\:' '{print $_i}' <<<$_input)
                        # echo FF: ${_sout[$i]}
                        _cperaw=${_sout[$i]#*\[\{\"cpe\"\:\ \"}
                        _cpe=${_cperaw%%\}\]\,\ \"m*}
                        _cperaw1=$(echo $_cpe | tr -d \" | tr -d { | tr -d } | tr -d ] | tr -d \[) 
                        _cpeport=${_cperaw1%?}
                        # echo $_cpeport
                        
                    else
                        _sout[$i]=$(awk -v _i="$i" -F'\{\"software\"\:' '{print $_i}' <<<$_input)
                        # echo 1_out[$i]: ${_sout[$i]}
                        # _portraw=${_out[$i]#*\"port\"\:\ }
                        _cperaw=${_sout[$i]#*\[\{\"cpe\"\:\ \"}
                        # _cpe=${_cperaw%%\"\}*}
                        _cperaw1=$(echo $_cperaw | tr -d \" | tr -d { | tr -d } | tr -d ] | tr -d \[) 
                        _cpeport=${_cperaw1%?}
                        
                    fi
                    echo "$_cpeport<br>">> Out_Files_Feed_"$_DIRUID".html
                    # echo _cpe: $_cpe
                    # echo _cpeport: $_cpeport
                    # _out[$i]=${_cpe%%\"\}\]\,\ } 
                    # echo _out[$i]: ${_out[$i]}
                done

               
                echo "<br><u>Whois Contacts:</u><br>" >> Out_Files_Feed_"$_DIRUID".html
                while read -r _aline; do
                    echo "$_aline<br>" >> Out_Files_Feed_"$_DIRUID".html
                done < abuse.txt
                
                mv email.txt OPENDIRS_"$_DIRUID"/whois_$_ipadd.txt
                rm abuse.txt
                
                
                if [ $_live == "true" ]; then
                    if [[ "$_port" == "443" ]]; then 
                        echo "<br><b><font color="green">Live URL:</font></b> <a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Out_Files_Feed_"$_DIRUID".html
                    else
                        echo "<br><b><font color="green">Live URL:</font></b> <a href=http://$_ipadd:$_port target="_blank" rel="noopener noreferrer">http://$_ipadd:$_port</a><br>" >> Out_Files_Feed_"$_DIRUID".html
                    fi
                else
                    if [[ "$_port" == "443" ]]; then 
                        echo "<br><b> <font color="red"> URL is inaccessible:</font></b> <a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Out_Files_Feed_"$_DIRUID".html
                    else
                        echo "<br><b> <font color="red"> URL is inaccessible: </font></b> <a href=http://$_ipadd:$_port target="_blank" rel="noopener noreferrer">http://$_ipadd:$_port</a><br>" >> Out_Files_Feed_"$_DIRUID".html
                    fi
                fi
                
                echo "<b>Dev Logs:</b> <a href=./OPENDIRS_"$_DIRUID"/$_cfname target="_blank" rel="noopener noreferrer">$_cfname</a>" >> Out_Files_Feed_"$_DIRUID".html
                echo "<br><b>Whois Logs:</b> <a href=./OPENDIRS_"$_DIRUID"/whois_$_ipadd.txt target="_blank" rel="noopener noreferrer">$_ipadd contact details (raw json)</a>" >> Out_Files_Feed_"$_DIRUID".html

                echo "<br><br><i>Last Updated: $_lupdate Z</i><br>" >> Out_Files_Feed_"$_DIRUID".html
                echo "<br><br><hr width="100%" size="1"><br>" >> Out_Files_Feed_"$_DIRUID".html
                
                # Remove working file #
                rm -rf "$_cfname"
            # else
                
            #     # Remove working file #
            #     rm -rf "$_cfname"
            
            # fi # end of if [[ $_sz -gt 0 ]]; then 
        
        # fi # end of if [ $? -ne 0 ] ; then

    done # end of for ((i=0; i<_occurances; i++))

    # move Censys response to storage folder #
    mv "$_UID"_output.txt OPENDIRS_"$_DIRUID"
    
    if [ -z "$_next" ]
    then
        echo "This is the last entry, quitting.."
        
        echo "<br><b>Total Records Found:</b>" $_total >> Out_Files_Feed_"$_DIRUID".html
        echo "<br><b>Servers accessible:</b> $_recread<br>">> Out_Files_Feed_"$_DIRUID".html

        # Close HTML file tags #
        echo "</body>" >> Out_Files_Feed_"$_DIRUID".html
        echo "</html>" >> Out_Files_Feed_"$_DIRUID".html
        echo "</body>" >> OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html
        echo "</html>" >> OPENDIRS_"$_DIRUID"/Files_Error_Feed_"$_DIRUID".html
        
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