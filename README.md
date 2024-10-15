# **YARROW** 
### An open-source Internet scanner that monitors open-directories and detects phishing pages.
<br><br>

Yarrow, an open-source and modular internet scanner that assists in the passive detection of:
- Module 1: Servers with open directories that list executables and 
- Module 2: Server that hosts phishing pages. 

Yarrow's first module intends to ensure that the interet is a safe and secure space by passively blocking threats without actions such as installation of anti-virus or other software(s) by end users. This scanner detects malware on Command and Control (C2) servers, inform the webhosts (admin and abuse contacts), and publishes a list of servers as non-commerical open-source lists. 

Yarrow's second module detects phishing pages across the internet for various email providers via a Ruleset Database (RSD) inspired from Yara rules. RSD is an open-source plugin that will enable detection of any phishing page for email, corporate logins, payment providers, or other pages that may be used to malicisouly harvest credentials. 

Yarrow is supported as a research project by Censys API that enables internet scanning for both the modules. Yarrow uses the results and then drills further by obtaining Portable Executable (EXE) checksums and then analyses them across several malware databases. 

Yarrow is published an open-source non-commerical platform that generates feeds containing list of Servers that host malicious files or phishing pages under MIT license.
<br><br>

**Task List for module**
- [ ] Bridge with malware database
- [ ] Integtate with domain datasbase
- [ ] Generate RSD

<br><br>
**Project Supported by:**<br>
Censys (www.censys.io)
<br><br>
**Project Mentor**: Dr. Nived Chebrolu, Oxford University<br>
**Project Founder**: Aadya Srivastava, Student at NAS Dubai<br>
<br><br>
# How to setup?
Since Yarrow is coded in bash script it will run across all Mac OS, Linux, FreeBSD and other open-source operating systems. 

Download the file: yarrow_opendirs.sh to your computer and enter Censys API credentials in line 7 and save the file.

To run the platorm simply download the file to a location and type the following in the terminal:

`chmod +x yarrow_opendirs.sh
`

`./yarrow_opendirs.sh
`
<br><br>
Yarrow will create the following outputs:
- Timestamped folder that will save the results from Censys,
- Unique files that contain the list of IP and port number of servers
- Feed file that contains the list of IP and port number of servers in the format:

        Timestamp    IP    Port    Full URL
        ------------------------------------

<br><br>
# Access Feed File

Feed files are available in folder, "Feed" within repository that contains files that bear the filename of the day and time they were created. The files are space delimited. These files can be downloaded, freely used, distributed, or re-packaged with a citation to Censys, Yarrow, and other partners. For more information please contact me at yarrow@___.com
