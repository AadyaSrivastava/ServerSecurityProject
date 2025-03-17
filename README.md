# **ServerSecurityProject (SSP)** 
### An open-source passive Internet scanner that detects phishing or crdential harvesting pages.
<br>
SSP is an open-source modular internet scanner that passively detects servers hosting malicous pages for credential harvesting. SSP utilizes Censys' data-feeds to detect suspicious pages which are then scanned by SSP's internal engine that uses fuzzy-logic and assigned weights to accurately determine phishing pages. The platform has been programmed in bash and HTML to ensure low overhead and interoperability across the Linux, FreeBSD, MacOS, and other open-source OSes. SSP has two modules: <br><br>

<ins>Module 1:</ins> Downloads suspicious websites using Censys data-feeds. This module is editable so that the user may initiate downloads of other credential harvesting websites, corporate login, or run customized scans across the Censys' supplied data-feeds;<br>
<ins>Module 2:</ins> Downloads HTML, javascripts, and connected resources of suspicious pages as obtained in module 1 for offline analysis; and<br>
<ins>Module 3:</ins> Detects phishing pages using defined fuzzy logic and weights. This section is embedded within module 2 and is editable ensuring that the user may change the logic and weights to detect custom credential harvesting phishing site(s).    
<br><br>
<ins>SSP's first module</ins> intends to ensure that the internet is a safe and secure virtual space by passively scanning and blocking threats without end-user actions. This module passively detects malware on internet hosted Command and Control (C2) servers, inform the webhosts (admin and abuse contacts) of the vulnerability, and then publishes a list of such servers as non-commerical open-source lists. This module enables security of end-users such as schools, hospitals, non-profit, or other organisations that may not afford the purchase of expensive anti-virus and security software licenses. 
<br><br>
<ins>SSP's second module</ins> detects misconfigured servers that host documents, databases, or other files that may contain passwords (/etc/passwd, sql credentials, and others) and then informs the webhost owners. 
<br><br>
<ins>SSP's third module</ins> detects phishing pages across the internet for various email providers via a Ruleset Database (RSD) inspired from Yara rules. RSD is an open-source plugin that enables detection of any phishing page for email, corporate logins, payment providers, or other pages that malicisously harvest credentials. 
<br><br>
<ins>About SSP:</ins><br>SSP is as open-source research project mentored by Dr. Nived Chebrolu (Oxford University) and supported by Censys (censys.com, that originated at University of Michigan) that publishes a monthly open-source (MIT license) server feed and follows a non-disclosure policy of 45 days. The 45 days disclosure may be extended on request of the hosting provider or website owner
asdaasd
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
# Setup and Running
SSP is developed in bash script it will run across all Mac OS, Linux, FreeBSD and other open-source operating systems.  

Step 1: Download the files in the source directory (SRC) and enter Censys API credentials in line 12 of module1.sh.

Step 2: Grant permissions to all three files by typing the following in the terminal:

`chmod +x main.sh`<br>
`chmod +x module1.sh`<br>
`chmod +x module2.sh`<br>
`chmod +x module3.sh`<br>
<br>
Step 3: Run the main file:<br>
`./main.sh`
<br><br>
SSP creates the following outputs:
- Timestamped folder that will save the results from Censys,
- Unique files that contain the list of IP and port number of servers
- HTML encoded Feed file containing IP, port number, location (City, Country), Server OS, installed software, URL, and detilaed logs.

<br><br>
# Access Feed File

Feed files are available in folder, "feed" within the repository that contains files that bear the filename of the day and time they were created. These files can be downloaded, freely used, distributed, or re-packaged with a citation to Dr. Nived Chebrolu, Aadya Srivastava, Censys, SSP, and other partners. For more information or you would like to gain access to raw scanning logs then please contact us at contact [at] serversecurityproject [.] com<br><br>

<ins>For raw scanning logs</ins>: We are happy to provide raw scanning logs and would request the following information:<br>
Name of site:<br>
URL:<br>
Project Founders (name and email):<br>
How do you intend to use the logs (just a few lines):<br>

