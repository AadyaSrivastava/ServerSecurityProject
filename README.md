# **ServerSecurityProject (SSP)** 
### An open-source passive Internet scanner that monitors open-directories and detects phishing pages.
<br>
SSP is an open-source and modular internet scanner that assists in the passive detection of:<br>
- Module 1: Servers with open directories that host malicious executables, files;<br>
- Module 2: Server that are misconfigures and host documents, databases, or other proprietary information; and<br>
- Module 3: Detects phishing pages (customisable by a user to detect phishing against their own organisation).   
<br><br>
<ins>SSP's first module</ins> intends to ensure that the internet is a safe and secure virtual space by passively scanning and blocking threats without end-user actions. This module passively detects malware on internet hosted Command and Control (C2) servers, inform the webhosts (admin and abuse contacts) of the vulnerability, and then publishes a list of such servers as non-commerical open-source lists. This module enables security of end-users such as schools, hospitals, non-profit, or other organisations that may not afford the purchase of expensive anti-virus and security software licenses. 
<br><br>
<ins>SSP's second module</ins> detects misconfigured servers that host documents, databases, or other files that may contain passwords (/etc/passwd, sql credentials, and others) and then informs the webhost owners. 
<br><br>
<ins>SSP's third module</ins> detects phishing pages across the internet for various email providers via a Ruleset Database (RSD) inspired from Yara rules. RSD is an open-source plugin that enables detection of any phishing page for email, corporate logins, payment providers, or other pages that malicisously harvest credentials. 

SSP is as open-source research project mentored by Dr. Nived Chebrolu (Oxford University) and supported by Censys (censys.com, that originated at University of Michigan) that publishes an open-source (MIT license) server feed and follows a non-disclosure policy of 45 days. The 45 days disclosure may be extended on request of the hosting provider or website owner

<br><br>


**Pending Task List**
- [ ] Bridge with malware database
- [ ] Integtate with Whois datasbase
- [ ] Generate RSD

<br><br>
**Project Supported by:**<br>
Censys (www.censys.com)
<br><br>
<ins>Project Mentor:</ins>  Dr. Nived Chebrolu, Oxford University<br>
<ins>Project Founder:</ins> Aadya Srivastava, Student at NAS Dubai<br>
<br><br>
# How to setup?
SSP is developed in bash script it will run across all Mac OS, Linux, FreeBSD and other open-source operating systems.  

Step 1: Download the files in the source directory (SRC) and enter Censys API credentials in line 7 of module1.sh.

Step 2: Grant permissions to all three files by typing the following in the terminal:

`chmod +x main.sh
`chmod +x main.sh

`chmod +x module1.sh
`chmod +x module2.sh

Step 3: Run the main file:
`./main.sh
`
<br><br>
SSP creates the following outputs:
- Timestamped folder that will save the results from Censys,
- Unique files that contain the list of IP and port number of servers
- Feed file that contains the timestampe (space delimited Date and Time) list of IP and port number of servers in the format:

        Timestamp    IP    Port    Full URL   Ref_file   Ref_feed
        ---------------------------------------------------------

<br><br>
# Access Feed File

Feed files are available in folder, "Feed" within repository that contains files that bear the filename of the day and time they were created. The files are space delimited. These files can be downloaded, freely used, distributed, or re-packaged with a citation to Censys, Yarrow, and other partners. For more information please contact me at yarrow@kidsforreading.com
