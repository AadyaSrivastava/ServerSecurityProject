#!/bin/bash
clear
_rootdir=$(pwd)

# User Agent #
# _UA='"Yarrow Open-Source Scanner V1.00.011024.A"'
_UA='"Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36"'

_outdir="$_rootdir"/output

ls "$_rootdir"/sourcedata > srcdir.txt
mkdir "$_outdir"
# Set output folder name UID #
_DIRUID=$(date '+%d_%m_%Y_%H_%M_%S')

# generate heading of CSV
echo "ctime","country","city","postcode","dnsnames","ipadd","port","abusect","orgname","bgp_prefix","asncode","asnname","self_ca","tls_serial","tls_issuerdn,phishcheck1","phishcheck2","phishcheck3","phishcheck4","phishcheck5","phishcheck6","phishcheck7","phishcheck8","phishcheck9","other_names" > Live_Feed_Gmail_"${_DIRUID}".csv
echo "ctime","country","city","postcode","dnsnames","ipadd","port","abusect","orgname","bgp_prefix","asncode","asnname","self_ca","tls_serial","tls_issuerdn,phishcheck1","phishcheck2","phishcheck3","phishcheck4","phishcheck5","phishcheck6","phishcheck7","phishcheck8","phishcheck9","other_names" > Review_Feed_Gmail_"${_DIRUID}".csv
echo "ctime","country","city","postcode","dnsnames","ipadd","port","abusect","orgname","bgp_prefix","asncode","asnname","self_ca","tls_serial","tls_issuerdn,phishcheck1","phishcheck2","phishcheck3","phishcheck4","phishcheck5","phishcheck6","phishcheck7","phishcheck8","phishcheck9","other_names" > Inactive_Feed_Gmail_"${_DIRUID}".csv

# generate HTML framework for report file
echo "<html>" >> Report_Gmail_"$_DIRUID".html
echo "<head>" >> Report_Gmail_"$_DIRUID".html
echo "<style>" >> Report_Gmail_"$_DIRUID".html
echo "body {" >> Report_Gmail_"$_DIRUID".html
echo "margin-top: 0px;" >> Report_Gmail_"$_DIRUID".html
echo "margin: 10;" >> Report_Gmail_"$_DIRUID".html
echo "padding: 0;" >> Report_Gmail_"$_DIRUID".html
echo "}" >> Report_Gmail_"$_DIRUID".html
echo "table, th, td {">> Report_Gmail_"$_DIRUID".html
echo "    border: 1px solid black;">> Report_Gmail_"$_DIRUID".html
echo "    border-collapse: collapse;">> Report_Gmail_"$_DIRUID".html
echo "}">> Report_Gmail_"$_DIRUID".html
echo "th, td {">> Report_Gmail_"$_DIRUID".html
echo "  padding: 5px;">> Report_Gmail_"$_DIRUID".html
echo "}">> Report_Gmail_"$_DIRUID".html
echo "</style>" >> Report_Gmail_"$_DIRUID".html
echo "</head>" >> Report_Gmail_"$_DIRUID".html




while read -r _fname; do 
    _ctime=$(date '+%d:%m:%Y %H:%M:%S')
    _UID=$(date '+%d_%m_%Y_%H_%M_%S')
    _input=$(cat "$_rootdir"/sourcedata/$_fname)
 
    # Get Mactched Services Element #
    _melementraw=${_input#*\"matched_services\"\:\ }
    _melement=${_melementraw%%\"links\"\:*}
   
    # Get Total #
    _rawdata=${_input#*\"total\"\:\ }
    _total=${_rawdata%%\,\ \"*}

    # Get IP Address
    _rawdata=${_input#*\"ip\"\:\ \"}
    _ipadd=${_rawdata%%\"\,*}

    # Get Post Code
    _rawdata=${_input#*\"postal_code\":\ \"}
    _postcode=${_rawdata%%\"*}
    _postcode=$(echo $_postcode | tr ',' '_')
    
    # Get City
    _rawdata=${_input#*\"city\"\:\ \"}
    _city=${_rawdata%%\"*}
    _city=$(echo $_city | tr ',' '_')

    # Get Country
    _rawdata=${_input#*\"country_code\"\:\ \"}
    _country=${_rawdata%%\"*}

    # Get Abuse Contact email
    if [[ $_input == *\"email* ]]; then
        _rawdata=${_input#*\"email\"\:\ \"}
        _abusect=${_rawdata%%\,\ \"*}
        _abusect=$(echo $_abusect | tr -d "}" | tr -d "]" | tr -d \")
        echo $_abusect > email_data.txt
    else
        _abusect=$(whois $_ipadd | grep mail)
        echo $_abusect > email_data.txt
        # echo _email_data: $_email_data
        # exit
    fi

    _abusect1=$(grep -i -o '[A-Z0-9._%+-]\+@[A-Z0-9.-]\+\.[A-Z]\{2,4\}' email_data.txt)
    _abusect=$(echo $_abusect1 | sed 's/ /,/g')

    # Get Next Cursor
    _rawdata=${_input#*\"next\"\:\ \"}
    _next=${_rawdata%%\"\,\ \"*}

    # Last updated #
    _rawdata=${_input#*\"last_updated_at\"\:\ \"}
    _lupdate=${_rawdata%%Z\"\,\ *}
    
    _othocc=false
    _othernames=$(echo -n "$_input" | grep -Fo '"name":' | wc -l)
    if [[ $_othernames -gt 0 ]]; then
        _othocc=true
        _nameoccurances=$(echo -n "$_input" | grep -Fo '"name":' | wc -l)
        echo _nameoccurances: $_nameoccurances

        for ((i=2; i<_nameoccurances+2; i++))
        do
            _outnames[$i]=$(awk -v _i="$i" -F'\"name":\ \"' '{print $_i}' <<<$_input)
            _outnames[$i]=$(echo "${_outnames[$i]}" | awk -F'"' '{print $1}' )
            # echo _out[$i]: ${_out[$i]}
            echo othname $i: ${_outnames[$i]}
        done

    fi

    echo allothernames: "$(IFS=,; echo "${_outnames[*]}")"
    # IFS=,
    # echo allothernames: ${_outnames[*]}

    # _delim=""
    # for _item in "${_outnames[@]}"; do
    # printf "%s" "${_delim}${_item}"
    # _delim=","
    # done
    
    # DNS Names #
    _dnsoccurances=$(echo -n "$_input" | grep -Fo '"dns"' | wc -l)
    if [[ $_dnsoccurances -gt 0 ]]; then
        _rawdata=${_input#*\"dns\":\ \{\"}
        _dnsnames=${_rawdata%%\}*}
        _dnsnames=$(echo $_dnsnames | tr -d "{" | tr -d "[" | tr -d "]" | tr -d "\"names\":" )
        
    else
        _dnsnames=$(echo "DNS not found")
    fi    

    # on-screen logging below
    # echo _dnsnames: $_dnsnames

    # Get Org Name
    _orgoccurances=$(echo -n "$_input" | grep -Fo '"organization"' | wc -l)
    if [[ $_orgoccurances -gt 0 ]]; then
        _rawdata=${_input#*\"organization\":\ \{\"}
        _rawdata2=${_rawdata#*\"name\"\:}
        _orgname=${_rawdata2%%\}*}
        _orgname=$(echo $_orgname | tr ',' '_')
    else
        _orgname=$(echo "Org not found")
    fi

    # on-screen logging below
    # echo _orgname: $_orgname

    # Get ASN Code and ASN Name
    _rawdata=${_input##*\"autonomous_system\":\ \{\"}
    _rawdata2=${_rawdata##*asn\"\:}
    _asncode=${_rawdata2%%\,\ \"*}
    _rawdata3=${_rawdata#*\"name\"\:}
    _asnname1=${_rawdata3%%\"\}\,*}
    _asnname=$(echo $_asnname1 | tr -d "\"")
    _rawdata4=${_rawdata##*bgp_prefix\"\:\ \"}
    # _rawdata4=${_rawdata#*\{\"bgp_prefix\"\:\ *}
    _bgp_prefix=${_rawdata4%%\"\,*}

    # on-screen logging below
    # echo _asncode: $_asncode
    # echo _asnname: $_asnname
    # echo _bgp_prefix: $_bgp_prefix

    # Get TLS Details
    # echo _fname: $_fname
    _tlsinfo=false
    _tlsoccurances=$(echo -n "$_input" | grep -Fo '"tls"' | wc -l)
    if [[ $_tlsoccurances -gt 0 ]]; then
        _tlsinfo=true
        _rawdata=${_input##*\"tls\":\ \{\"}
        _rawdata2=${_rawdata#*\"self_signed\"\:}
        _self_ca=${_rawdata2%%\}\,*}
        _rawdata3=${_rawdata##*\"serial_number\"\:\ \"}
        _tls_serial=${_rawdata3%%\"\,*}
        _rawdata4=${_rawdata##*\"issuer_dn\"\:\ \"}
        _tls_issuerdn=${_rawdata4%%\"\}\,*}
        _tls_issuerdn=$(echo $_tls_issuerdn | tr ',' '_') #safe encode

        _rawdata5=${_rawdata##*\"names\"\:}
        _tls_names1=${_rawdata5%%\]\}*}
        _tls_names=$(echo $_tls_names1 | tr -d "[" )
        _tls_names=$(echo $_tls_names | tr ',' '_') #safe encode
       

        # on-screen logging below
        # echo _self_ca: $_self_ca
        # echo _tls_serial: $_tls_serial
        # echo _tls_issuerdn: $_tls_issuerdn
        # echo _tls_names: $_tls_names
        
    fi


    # Get OS cpe #
    _cpeinfo=false
    _softoccurances=$(echo -n $_input | grep -Fo '"software":' | wc -l)
    if [[ $_softoccurances -gt 0 ]]; then
        _cpeinfo=true
        _rawdata=${_input#*\"software\":}
        # echo _rawdata: $_rawdata
        _cpeoccurances=$(echo -n $_input | grep -Fo '"cpe:' | wc -l)
        echo _cpeoccurances: $_cpeoccurances
        for ((i=2; i<_cpeoccurances+2; i++))
        do
            _cpeout[$i]=$(awk -v _i="$i" -F'\"cpe:' '{print $_i}' <<<$_rawdata)
            # echo 1_out[$i]: ${_out[$i]}
            _cpeout[$i]=$(echo "${_cpeout[$i]}" | awk -F'"}' '{print $1}' )
            echo _cpeout[$i]: ${_cpeout[$i]}
           
        done

    fi
    
    # Get occurances of ports in response
    _occurances=$(echo -n $_melement | grep -Fo '"port":' | wc -l)
    
    # Get port numbers in response and load them in an array #
    for ((i=2; i<=_occurances+1; i++))
    do
        _out[$i]=$(awk -v _i="$i" -F'\"port\"\:' '{print $_i}' <<<$_melement)
        _portraw=${_out[$i]#*\"port\"\:\ }
        _out[$i]=${_portraw%%\}*} 
    done
    
    # Generate Feed for all ports that are accessbile for a IP#
    for ((i=2; i<=_occurances+1; i++))
    do
        # Parse port and get file listing from remote server #
        _port=$(echo ${_out[$i]} | tr -d ' ')
   
        # generate temorary filename #
        _cfname=$(echo Gmail_"$_UID"-"$_ipadd"-"$_port".html)
        _cfnmtxt=$(echo Gmail_"$_UID"-"$_ipadd"-"$_port".txt)
        echo "Query Log: $_ipadd:$_port"
   
        # Get suspected phishing page from live server #
        if [[ "$_port" == "443" ]]; 
            then 
                # _curlstatus=$(curl -k --connect-timeout 30 -L -A "$_UA" https://"$_ipadd":"$_port" -o "$_cfname" 2>&1)
                _curlstatus=$(curl -k -m 60 -L -A "$_UA" https://"$_ipadd":"$_port" -o "$_cfname")
            else
                # _curlstatus=$(curl --connect-timeout 30 -L -A "$_UA" http://"$_ipadd":"$_port" -o "$_cfname"  2>&1)
                _curlstatus=$(curl -m 60 -L -A "$_UA" http://"$_ipadd":"$_port" -o "$_cfname")
        fi
    
        if [[ $? -ne 0 ]] ; 
            then
                ((_errors=_errors+1))
                _live=false
                _phishcheck1='NA'
                _phishcheck2='NA'
                _phishcheck3='NA'
                _phishcheck4='NA'
                _phishcheck5='NA'
                _phishcheck6='NA'
                _phishcheck7='NA'
                _phishcheck8='NA'
                _phishcheck9='NA'
                echo "$_ctime","$_country","$_city","$_postcode","$_dnsnames","$_ipadd","$_port","$_abusect","$_orgname", "$_bgp_prefix", "$_asncode", "$_asnname", "$_self_ca", "$_tls_serial", "$_tls_issuerdn,$_phishcheck1", "$_phishcheck2", "$_phishcheck3", "$_phishcheck4", "$_phishcheck5", "$_phishcheck6", "$_phishcheck7", "$_phishcheck8", "$_phishcheck9", "$(IFS=,; echo "${_outnames[*]}")" >> Inactive_Feed_Gmail_"$_DIRUID".csv
                echo "Downloading of remote phishing site encoutered a timeout for "$_ipadd":"$_port" at "$_ctime""
                echo "Case logged in file "$_outdir"/TIMEOUT_"$_DIRUID".html"
                echo "$_ctime,$_country,$_city,<a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> "$_outdir"/TIMEOUT_"$_DIRUID".html
                
                    
            else
                _live=true
                _mailapp=false
                cp "$_cfname" "$_cfnmtxt"
                _interimdata=$(cat "$_cfnmtxt")
                if [[ $_interimdata == *"method=\"post\""* ]]; then
                    _mailapp=true
                fi
                if [[ $_interimdata == *"method=\"POST\""* ]]; then
                    _mailapp=true
                fi
                if [[ $_interimdata == *"method=\"Post\""* ]]; then
                    _mailapp=true
                fi
   
                if [[ $_mailapp == "true" ]]; then

                    # Valid reply found #
                    ((_recread=_recread+1))
                    
                    _phishcheck1=true
                    _phishcheck2=true
                    _phishcheck3=true
                    _phishcheck4=true
                    _phishcheck5=true
                    _phishcheck6=true
                    _phishcheck7=true
                    _phishcheck8=true
                    _phishcheck9=true
                    
                    # does file contain base URL
                    _validate1=$(cat "$_cfnmtxt" | grep -Fo '<base href="https://accounts.google.com/v3/signin/">' | wc -l)
                    if [[ "$_validate1" == 0 ]]; then
                        _phishcheck1=false
                    fi

                    # does file contain Google
                    if [[ $_interimdata == *"Gmail"* ]]; then
                        if [[ $_dnsnames == *"google"* ]]; then
                            _phishcheck2=false
                        fi
                    fi

                    # does file contain nofollow
                    if [[ $_interimdata != *"nofollow"* ]]; then
                        _phishcheck3=false
                    fi

                    if [[ $_interimdata != *"hidden"* ]]; then
                        _phishcheck4=false
                    fi

                    if [[ $_interimdata != *"type=\"email\""* ]]; then
                        _phishcheck4=false
                    fi
                    
                    if [[ $_interimdata != *"href=\"#\">"* ]]; then
                        _phishcheck5=false
                    fi
                    

                    if [[ $_interimdata != *"password"* ]]; then
                        _phishcheck6=false
                    fi
                    
                    if [[ $_interimdata != *"Password"* ]]; then
                        _phishcheck7=false
                    fi

                    if [[ $_interimdata != *"to continue to Gmail"* ]]; then
                        _phishcheck8=false
                    fi

                    if [[ $_interimdata != *"to continue to gmail"* ]]; then
                        _phishcheck9=false
                    fi
                    
                    # echo _phishcheck: $_phishcheck
                    mv "$_cfname" "$_outdir"
                    mv "$_cfnmtxt" "$_outdir"
                    
                else
                    mv "$_cfname" "$_rootdir"/ignored
                    mv "$_cfnmtxt" "$_rootdir"/ignored
                fi # mail app is true master loop
                
                           
                
        fi # end of if [ $? -ne 0 ] ; then

        # echo _curlstatus: $_curlstatus _live: $_live 
    

        if [[ $_mailapp == "true" ]]; then
            
            

            # Save file lists in feed for production #
            echo "<table>" >> Report_Gmail_"$_DIRUID".html
            
            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>Server IP:</b></td> <td>$_ipadd</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html
            
            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>Server Port:</b></td> <td> $_port</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>Abuse Contact:</b></td> <td> $_abusect</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>Server Location (Post Code):</b></td> <td> $_postcode</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>Server Location (City, Country):&nbsp;&nbsp; </b></td> <td> $_city, $_country</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>Organisation:</b></td> <td> $_orgname</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>BGP Prefix:</b></td> <td> $_bgp_prefix</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>ASN Code:</b></td> <td> $_asncode</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html
            
            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>ASN Name:</b></td> <td> $_asnname</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            echo "<tr>" >> Report_Gmail_"$_DIRUID".html
            echo "<td><b>DNS Name:</b></td> <td> $_dnsnames</td>" >> Report_Gmail_"$_DIRUID".html
            echo "</tr>" >> Report_Gmail_"$_DIRUID".html

            
            if [[ "$_othocc" == true ]]; then
                echo "<tr>" >> Report_Gmail_"$_DIRUID".html
                echo "<td><b>Other Names:</b></td><td> </td>" >> Report_Gmail_"$_DIRUID".html
                echo "</tr>" >> Report_Gmail_"$_DIRUID".html
                for ((i=2; i<_nameoccurances+2; i++))
                do
                    echo "<tr>" >> Report_Gmail_"$_DIRUID".html
                    echo "<td> </td><td> ${_outnames[$i]}  </td>">> Report_Gmail_"$_DIRUID".html
                    echo "</tr>" >> Report_Gmail_"$_DIRUID".html
                done
            fi
            echo "</table>" >> Report_Gmail_"$_DIRUID".html
            

            if [[ "$_tlsinfo" == true ]]; then
                echo "<br><br><b><u>TLS/SSL Information:</u></b>" >> Report_Gmail_"$_DIRUID".html  
                echo "<br>Names in SSL: $_tls_names" >> Report_Gmail_"$_DIRUID".html  
                echo "<br>Self-signed SSL: $_self_ca" >> Report_Gmail_"$_DIRUID".html  
                echo "<br>TLS/SSL Serial:$_tls_serial" >> Report_Gmail_"$_DIRUID".html  
                echo "<br>TLS/SSL Issuer: $_tls_issuerdn" >> Report_Gmail_"$_DIRUID".html      
            fi
            if [[ "$_cpeinfo" == true ]]; then
                echo "<br><br><b><u>Server software:</u></b><br>" >> Report_Gmail_"$_DIRUID".html  
                for ((i=2; i<_cpeoccurances+2; i++))
                do
                    echo "${_cpeout[$i]} <br>">> Report_Gmail_"$_DIRUID".html
                done
               
                echo "<br>" >> Report_Gmail_"$_DIRUID".html
            fi
           
            echo "<br><u><b>Fuzzy Logic Results:</b></u>" >> Report_Gmail_"$_DIRUID".html
            if [[ "$_phishcheck1" == "true" ]]; then echo "<br><font color="blue">Rule 1: Review of code confirms that this is not a Google site but has a lot of references to Google</font>" >> Report_Gmail_"$_DIRUID".html; fi; 
            if [[ "$_phishcheck2" == "true" ]]; then echo "<br><font color="blue">Rule 2: Reverse DNS is not owned by Google</font>" >> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck3" == "true" ]]; then echo "<br><font color="blue">Rule 3: Site has suspicious tags to avoid indexation</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck4" == "true" ]]; then echo "<br><font color="blue">Rule 4: Site does contains a email input prompt</font>">> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck5" == "true" ]]; then echo "<br><font color="blue">Rule 5: Site has missing links</font>">> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck6" == "true" ||  "$_phishcheck7" == "true" ]]; then echo "<br><font color="blue">Rule 6 and 7: Site does contains a password input prompt</font>">> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck8" == "true" ||  "$_phishcheck9" == "true" ]]; then echo "<br><font color="blue">Rule 8: Site text that indicates phishing, case 8</font>">> Report_Gmail_"$_DIRUID".html; fi;
            
            echo "<br>" >> Report_Gmail_"$_DIRUID".html
            
            if [[ $_live == "true" ]]; 
            then
                
                echo "$_ctime","$_country","$_city","$_postcode","$_dnsnames","$_ipadd","$_port","$_abusect","$_orgname", "$_bgp_prefix", "$_asncode", "$_asnname", "$_self_ca", "$_tls_serial", "$_tls_issuerdn,$_phishcheck1", "$_phishcheck2", "$_phishcheck3", "$_phishcheck4", "$_phishcheck5", "$_phishcheck6", "$_phishcheck7", "$_phishcheck8", "$_phishcheck9", "$(IFS=,; echo "${_outnames[*]}")" >> Live_Feed_Gmail_"$_DIRUID".csv
                echo "Logging line:">> Report_Gmail_"$_DIRUID".html
                echo "<br>" >> Report_Gmail_"$_DIRUID".html
                echo "$_ctime","$_country","$_city","$_postcode","$_dnsnames","$_ipadd","$_port","$_abusect","$_orgname", "$_bgp_prefix", "$_asncode", "$_asnname", "$_self_ca", "$_tls_serial", "$_tls_issuerdn,$_phishcheck1", "$_phishcheck2", "$_phishcheck3", "$_phishcheck4", "$_phishcheck5", "$_phishcheck6", "$_phishcheck7", "$_phishcheck8", "$_phishcheck9", "$(IFS=,; echo "${_outnames[*]}")" >> Report_Gmail_"$_DIRUID".html
                echo "<br>" >> Report_Gmail_"$_DIRUID".html
                
                if [[ "$_port" == "443" ]]; then 
                    echo "<br><b><font color="green">Live URL:</font></b> <a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html
                    
                else
                    echo "<br><b><font color="green">Live URL:</font></b> <a href=http://$_ipadd:$_port target="_blank" rel="noopener noreferrer">http://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html

                    
                fi
            else
                
                echo "$_ctime","$_country","$_city","$_postcode","$_dnsnames","$_ipadd","$_port","$_abusect","$_orgname", "$_bgp_prefix", "$_asncode", "$_asnname", "$_self_ca", "$_tls_serial", "$_tls_issuerdn,$_phishcheck1", "$_phishcheck2", "$_phishcheck3", "$_phishcheck4", "$_phishcheck5", "$_phishcheck6", "$_phishcheck7", "$_phishcheck8", "$_phishcheck9", "$(IFS=,; echo "${_outnames[*]}")" >> Review_Feed_Gmail_"$_DIRUID".csv
                
                if [[ "$_port" == "443" ]]; then 
                    echo "<br><b><font color="red">URL is inaccessible:</font></b> <a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html
                    echo "<br>Input Ref: $_fname <br>" >> Report_Gmail_"$_DIRUID".html
                    echo "Output Ref: $_cfname <br>" >> Report_Gmail_"$_DIRUID".html
                else
                    echo "<br><b><font color="red">URL is inaccessible:</font></b> <a href=http://$_ipadd:$_port target="_blank" rel="noopener noreferrer">http://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html
                    echo "<br>Input Ref: $_fname <br>" >> Report_Gmail_"$_DIRUID".html
                    echo "Output Ref: $_cfname <br>" >> Report_Gmail_"$_DIRUID".html
                fi
            fi

            if [[ $_live == "true" ]]; 
            then
                echo "<br><b>Raw Response Logs:</b> <a href='output/${_cfnmtxt}' target="_blank"> (View saved HTML as TXT)</a> <br>" >> Report_Gmail_"$_DIRUID".html
                echo "<iframe src='output/${_cfname}'\" style=\"height:200px;width:80%\" title=\"Raw Response Logs:\"></iframe>"  >> Report_Gmail_"$_DIRUID".html
                echo "<br>Input Ref: $_fname <br>" >> Report_Gmail_"$_DIRUID".html
                echo "Output Ref: $_cfname <br>" >> Report_Gmail_"$_DIRUID".html
        
            fi
            
            echo "<br><br><i>Last Updated: $_lupdate Z</i><br>" >> Report_Gmail_"$_DIRUID".html
            echo "<br><br><hr width="100%" size="3"><br>" >> Report_Gmail_"$_DIRUID".html

            
        fi
        
            
    done # end of for ((i=0; i<_occurances; i++))

done < input_feed.csv

echo "</html>" >> Report_Gmail_"$_DIRUID".html

