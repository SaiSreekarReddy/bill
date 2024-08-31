curl -u %USERNAME%:%PASSWORD% -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"assignee\":{\"name\":\"%ASSIGNEE_USERNAME%\"}}}" %JIRA_URL%/rest/api/2/issue/%TICKET_ID%


curl -u %USERNAME%:%PASSWORD% -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"assignee\":{\"accountId\":\"%ASSIGNEE_ACCOUNT_ID%\"}}}" %JIRA_URL%/rest/api/2/issue/%TICKET_ID%
