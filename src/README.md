This section contains the source code for the SSP platform as per the following files:
1. generate_db.sh:
   - Connects to Censys to download a list of suspcious files.
   - Add API passcode in variable `_auth` as username:password
   - Add components to query in variable `_query`
   - Add custom fields in `_custfields` to filter results from Censys 
   - For more information on Censys related API visit: https://search.censys.io/search/getting-started

2. generate_feed.sh:
   - This file contains the logical engine that downloads websites and undertakes fuzzy logic to determine if they are phishing pages. This file generates the HTML report and CSV feed.
