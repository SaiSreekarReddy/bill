curl -u your_username:your_password -X POST \
   -H "Content-Type: application/json" \
   -d '{"body": "This is a comment."}' \
   https://track.td.com/rest/api/2/issue/ISSUE-KEY/comment && \
curl -u your_username:your_password -X PUT \
   -H "Content-Type: application/json" \
   -d '{
         "update": {
           "labels": [
             {"add": "label1"},
             {"add": "label2"}
           ]
         }
       }' \
   https://track.td.com/rest/api/2/issue/ISSUE-KEY
