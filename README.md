# **YARROW** 
### An open-source Internet scanner
<br><br>

Is an open-source internet scanner that aims to passively detect (a) servers with open directories that list executables and (b) phishing pages. Yarrow uses Censys API and scans the internet for servers that have an open directory and contains executables in their file list. Yarrow drills further in the results and obtains the file's checksums (hashes) and then scans the output against several malware databases. 


Yarrow is also capable of detecting phishing pages across the internet for various email providers via a Ruleset Database (RSD) that is inspired from Yara rules. RSD is an open-source plugin that will enable detection of any phishing page for email, corporate logins, payment providers, or other pages that may be used to malicisouly harvest credentials. 


Yarrow published open-source feeds that contain list of Servers that host malicious files or phishing pages under MIT license

<br><br>
**Project Supported by:**<br>
Censys (www.censys.io)
<br><br>
**Project Mentor**: Dr. Nived Chebrolu, Oxford University<br>
**Project Founder**: Aadya Srivastava, Student at NAS Dubai<br>
