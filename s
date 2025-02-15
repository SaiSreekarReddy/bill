
    # Set the Jenkins server details
    local jenkins_url="http://<jenkins-server>/job/<your-job-name>/buildWithParameters"
    local jenkins_user="<jenkins-username>"
    local jenkins_token="<jenkins-api-token>"

    # Trigger the email-ext plugin
    curl -X POST "$jenkins_url" \
        --user "$jenkins_user:$jenkins_token" \
        --data-urlencode "recipients=$to" \
        --data-urlencode "cc=$cc" \
        --data-urlencode "subject=$subject" \
        --data-urlencode "body=$body" \
        --form "file0=@$attachment"
