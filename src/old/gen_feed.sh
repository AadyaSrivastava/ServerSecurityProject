#!/bin/bash
clear
echo "Enter root directory of data responses"
read _rootdir

# User Agent #
_UA='"Yarrow Open-Source Scanner V1.00.011024.A"'

_outdir="$_rootdir"/output

ls "$_rootdir"/sourcedata > srcdir.txt
mkdir "$_outdir"
echo "Time","Country","City","Postal","DNS","IP","Port","Contact","Organisation" >> Feed_Gmail_"$_rootdir".txt


# Set output folder name UID #
_DIRUID=$(date '+%d_%m_%Y_%H_%M_%S')


while read -r _fname; do 

    _UID=$(date '+%d_%m_%Y_%H_%M_%S')
    _input=$(cat "$_rootdir"/sourcedata/$_fname)
    
    # _input=$(cat 1729086323_Gmail_output.txt)

    # Get Mactched Services Element #
    _melementraw=${_input#*\"matched_services\"\:\ }
    _melement=${_melementraw%%\"links\"\:*}
    # echo $_melement
    # exit
    # Get Total #
    _rawdata=${_input#*\"total\"\:\ }
    _total=${_rawdata%%\,\ \"*}

    # Get IP Address
    _rawdata=${_input#*\"ip\"\:\ \"}
    _ipadd=${_rawdata%%\"\,*}

    # # Get Post Code
    # _rawdata=${_input#*\"postal_code\"\:\ \"}
    # _postcode=${_rawdata%%\"\,*}
    
    # # Get City
    # _rawdata=${_input#*\"city\"\:\ \"}
    # _city=${_rawdata%%\"\}*}

    # Get Post Code
    _rawdata=${_input#*\"postal_code\":\ \"}
    _postcode=${_rawdata%%\"*}
    
    # Get City
    _rawdata=${_input#*\"city\"\:\ \"}
    _city=${_rawdata%%\"*}

    # Get Country
    _rawdata=${_input#*\"country_code\"\:\ \"}
    # echo 11: $_rawdata
    _country=${_rawdata%%\"*}

    # # Get Abuse Contact email
    # _rawdata=${_input#*\"email\"\:\ \"}
    # _abusect=${_rawdata%%\,\ \"*}
    # _abusect=$(echo $_abusect | tr -d "}" | tr -d "]" | tr -d \")
    
     # Get Abuse Contact email
    # if echo "$string" | grep -q "$substring"
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
    # echo _rawdata: $_rawdata
    # echo _lupdate: $_lupdate

    # DNS Names #
    # _rawdata=${_input#*\"dns\"\:\ }
    # _dnsnames=${_rawdata%%\"\]\}*}
    # _dnsnames=$(echo $_dnsnames | tr -d "{" | tr -d "[" | tr -d "\"names\":" )
    _rawdata=${_input#*\"dns\":\ \{\"}
    _dnsnames=${_rawdata%%\}*}
    _dnsnames=$(echo $_dnsnames | tr -d "{" | tr -d "[" | tr -d "]" | tr -d "\"names\":" )

    # Get Org Name
    # _rawdata=${_input#*\"name\"\:\ \"}
    # _orgname=${_rawdata%%\"\}*}
    _rawdata=${_input#*\"name}
    _orgname=${_rawdata%%\}*}


    # Get OS cpe #
    _rawdata=${_input#*\"software\"\:\ \[*}
    _osCPE=${_rawdata%%\,\ \"matched_services\"*}
    # _osCPE=$(echo "$_osCPE" | sed 's/"tls":/<br>"tls data":<br>/g')
    _osCPE=$(echo "$_osCPE" | sed 's/"tls"://g')
    # _osCPE=$(echo "$_osCPE" | sed 's/"software":/<br>"software":<br>/g')
    _osCPE=$(echo "$_osCPE" | sed 's/"software"://g')
    # _osCPE=$(echo "$_osCPE" | sed 's/"cpe":/<br>"cpe":<br>/g')
    _osCPE=$(echo "$_osCPE" | sed 's/"cpe"://g')
    _osCPE=$(echo "$_osCPE" | sed 's/"cpe:/\n"cpe:/g')
    _osCPE=$(echo "$_osCPE" | sed 's/"certificate":/<br>"SSL Info":/g')
    _osCPE=$(echo $_osCPE | tr -d "{" | tr -d "[" | tr -d "]" | tr -d "}" )
    # _rawdata=${_input#*\"software\"\:\ \[*}
    # _osCPE=${_rawdata%%\,\ \"matched_services\"*}
# "tls":
    # _osCPE=$(echo "$_osCPE" | sed 's/"tls":/\n"tls":/g')
    # echo _osCPE: $_osCPE
    # echo _total: $_total 
    # echo _ipadd: $_ipadd 

    # echo _postcode: $_postcode
    # echo _city: $_city 
    # echo _country: $_country 
    # echo _abusect: $_abusect 
    # echo _lupdate: $_lupdate
    # echo _dnsnames: $_dnsnames
    
    # Get occurances of ports in response
    _occurances=$(echo -n $_melement | grep -Fo '"port":' | wc -l)
    # echo _occurances: $_occurances
    
    # Get port numbers in response and load them in an array #
    for ((i=2; i<=_occurances+1; i++))
    do
        _out[$i]=$(awk -v _i="$i" -F'\"port\"\:' '{print $_i}' <<<$_melement)
        # echo 1_out[$i]: ${_out[$i]}
        _portraw=${_out[$i]#*\"port\"\:\ }
        _out[$i]=${_portraw%%\}*} 
        # echo _out-port[$i]: ${_out[$i]}
    done
    
    # Generate Feed for all ports that are accessbile for a IP#
    for ((i=2; i<=_occurances+1; i++))
    do
        # Parse port and get file listing from remote server #
        _port=$(echo ${_out[$i]} | tr -d ' ')
        # echo PORT: $_port
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
                # echo "*****"
                # echo _mailapp: $_mailapp
                # echo "*****"
                if [[ $_mailapp == "true" ]]; then

                    # Valid reply found #
                    ((_recread=_recread+1))
                    
                    # _interimdata=$(cat "$_cfnmtxt")
                    _phishcheck1=true
                    _phishcheck2=true
                    _phishcheck3=true
                    _phishcheck4=true
                    _phishcheck5=true
                    _phishcheck6=true
                    _phishcheck7=true
                    
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
                    
                    # echo _phishcheck: $_phishcheck
                    mv "$_cfname" "$_outdir"
                    mv "$_cfnmtxt" "$_outdir"
                    
                else
                    mv "$_cfname" "$_rootdir"/ignored
                    mv "$_cfnmtxt" "$_rootdir"/ignored
                fi # mail app is true master loop
                
                           
                
        fi # end of if [ $? -ne 0 ] ; then

        # echo _curlstatus: $_curlstatus _live: $_live 
    

        if [ $_mailapp == "true" ]; then
            _ctime=$(date '+%d:%m:%Y %H:%M:%S')
            echo "$_ctime","$_country","$_city","$_postcode","$_dnsnames","$_ipadd","$_port","$_abusect","$_orgname" >> Feed_Gmail_"$_rootdir".txt
            
            # Save file lists in feed for production #
            echo "<br><b>Server IP:</b> $_ipadd" >> Report_Gmail_"$_DIRUID".html
            echo "<br><b>Server Port:</b> $_port" >> Report_Gmail_"$_DIRUID".html
            echo "<br><b>Server Location (Post Code):</b> "$_postcode"" >> Report_Gmail_"$_DIRUID".html
            echo "<br><b>Server Location (City, Country):</b> $_city, $_country" >> Report_Gmail_"$_DIRUID".html
            
            echo "<br><b>DNS Name:</b> $_dnsnames" >> Report_Gmail_"$_DIRUID".html
            echo "<br><b>Organisation:</b> $_orgname" >> Report_Gmail_"$_DIRUID".html
                
            echo "<br><br><u>Server software and TLS/SSL data:</u><br>" >> Report_Gmail_"$_DIRUID".html  
            echo "$_osCPE <br>">> Report_Gmail_"$_DIRUID".html
            echo "<br>" >> Report_Gmail_"$_DIRUID".html
            echo "<u>Abuse Contact:</u> $_abusect<br>" >> Report_Gmail_"$_DIRUID".html

            # echo "<table style="width:50%"> <tr> <td>Case 1</td><td>Case 2</td><td>Case 3</td><td>Case 4</td><td>Case 5</td><td>Case 6</td><td>Case 7</td></tr><tr><td>${_phishcheck1}</td><td>${_phishcheck2}</td><td>${_phishcheck3}</td><td>${_phishcheck4}</td><td>${_phishcheck5}</td><td>${_phishcheck6}</td><td>${_phishcheck7}</td>  </tr> </table><br>" >> Report_Gmail_"$_DIRUID".html


            # echo "<br><b><font color="red">${_phishcheck1} ${_phishcheck2} ${_phishcheck3} ${_phishcheck4} ${_phishcheck5} ${_phishcheck6} ${_phishcheck7} </font></b><br>" >> Report_Gmail_"$_DIRUID".html
            echo "<u>Page contains POST form:</u> $_mailapp<br>" >> Report_Gmail_"$_DIRUID".html
            # if [ "$_phishcheck1" == "true" ]; then echo "<br><b><font color="red">Review of code confirms that this is not a Google site but has a lot of references to Google.</font></b>" >> Report_Gmail_"$_DIRUID".html; else echo "<br><b><font color="green">Review of code confirms that this is a Google site.</font></b>">> Report_Gmail_"$_DIRUID".html; fi; 
            # if [ "$_phishcheck2" == "true" ]; then echo "<br><b><font color="red">Reverse DNS is not owned by Google.</font></b>" >> Report_Gmail_"$_DIRUID".html; else echo "<br><b><font color="green">Reverse DNS is owned by Google.</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            # if [ "$_phishcheck3" == "true" ]; then echo "<br><b><font color="red">Site has suspicious tags to avoid indexation</font></b>">> Report_Gmail_"$_DIRUID".html; else echo "<br><b><font color="green">Site does not has suspicious tags.</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            # if [ "$_phishcheck4" == "true" ]; then echo "<br><b><font color="red">Site does contains a email input prompt</font></b><br>">> Report_Gmail_"$_DIRUID".html; else echo "<br><b><font color="green">Site does not contain a email input prompt</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            # if [ "$_phishcheck5" == "true" ]; then echo "<br><b><font color="red">Site has missing links</font></b>">> Report_Gmail_"$_DIRUID".html; else echo "<br><b><font color="green">Site does not has suspicious tags.</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            # if [ "$_phishcheck6" == "true" ||  "$_phishcheck7" == "true" ]; then echo "<br><b><font color="red">Site does contains a password input prompt</font></b><br>">> Report_Gmail_"$_DIRUID".html; else echo "<br><b><font color="green">Site does not contain a password input prompt</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            
            if [[ "$_phishcheck1" == "true" ]]; then echo "<br><b><font color="red">Review of code confirms that this is not a Google site but has a lot of references to Google</font></b>" >> Report_Gmail_"$_DIRUID".html; fi; 
            if [[ "$_phishcheck2" == "true" ]]; then echo "<br><b><font color="red">Reverse DNS is not owned by Google</font></b>" >> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck3" == "true" ]]; then echo "<br><b><font color="red">Site has suspicious tags to avoid indexation</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck4" == "true" ]]; then echo "<br><b><font color="red">Site does contains a email input prompt</font></b><br>">> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck5" == "true" ]]; then echo "<br><b><font color="red">Site has missing links</font></b>">> Report_Gmail_"$_DIRUID".html; fi;
            if [[ "$_phishcheck6" == "true" ||  "$_phishcheck7" == "true" ]]; then echo "<br><b><font color="red">Site does contains a password input prompt</font></b><br>">> Report_Gmail_"$_DIRUID".html; fi;
            
            echo "<br>" >> Report_Gmail_"$_DIRUID".html
            
            if [[ $_live == "true" ]]; 
            then
                if [[ "$_port" == "443" ]]; then 
                    echo "<br><b><font color="green">Live URL:</font></b> <a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html
                    
                else
                    echo "<br><b><font color="green">Live URL:</font></b> <a href=http://$_ipadd:$_port target="_blank" rel="noopener noreferrer">http://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html
                fi
            else
                if [[ "$_port" == "443" ]]; then 
                    echo "<br><b><font color="red">URL is inaccessible:</font></b> <a href=https://$_ipadd:$_port target="_blank" rel="noopener noreferrer">https://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html
                else
                    echo "<br><b><font color="red">URL is inaccessible:</font></b> <a href=http://$_ipadd:$_port target="_blank" rel="noopener noreferrer">http://$_ipadd:$_port</a><br>" >> Report_Gmail_"$_DIRUID".html
                fi
            fi

            if [[ $_live == "true" ]]; 
            then
                echo "<br><b>Raw Response Logs:</b> <a href="./"$_outdir"/${_cfname}" target="_blank" rel="noopener noreferrer"> (View saved HTML)</a> <br>" >> Report_Gmail_"$_DIRUID".html
                echo "<iframe src=\".\/"$_outdir"/${_cfnmtxt}\" style=\"height:200px;width:80%\" title=\"Raw Response Logs:\"></iframe>"  >> Report_Gmail_"$_DIRUID".html
                echo "<br>Ref: $_fname <br>" >> Report_Gmail_"$_DIRUID".html
            fi

            # echo "<b>Dev Logs:</b> <a href=./Gmail_"$_DIRUID"/$_cfname target="_blank" rel="noopener noreferrer">$_cfname</a>" >> Report_Gmail_"$_DIRUID".html
            # echo "<br><b>Raw Response Logs:</b> <a href=./Gmail_"$_DIRUID"/${_cfnmtxt} target="_blank" rel="noopener noreferrer">$_ipadd HTTP Response (raw)</a>" >> Report_Gmail_"$_DIRUID".html
            
            echo "<br><br><i>Last Updated: $_lupdate Z</i><br>" >> Report_Gmail_"$_DIRUID".html
            echo "<br><br><hr width="100%" size="1"><br>" >> Report_Gmail_"$_DIRUID".html

            
        fi
        
            
    done # end of for ((i=0; i<_occurances; i++))
    

    

done < srcdir.txt
