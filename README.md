# EMAIL SENDER

## SETUP
* install google dependendies run  
```pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib```
* setup venv for python  
* activate venv  
* install dependencies from requirements.txt by running:  
```pip install -r requirements.txt```
* create a `credentials.json` file  
* give the client proper scopes and update `send_email.py` accordingly  
* create a `.env` file in the folder of the project  
and fill in the following values  
``` 
SERVICE_EMAIL=your@email.address  
```  

## RUN  

```.\detect_change.ps1 /relative/or/absolute/path/to/your/folder```  

use PowerShell in windows  

** no linux\mac support yet  
