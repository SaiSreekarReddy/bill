sendmail -v
send_email_ext() {
    local to="$1"
    local cc="$2"
    local subject="$3"
    local body="$4"
    local attachments="$5" # Optional for attachments

    # Construct the email-ext command
    local command="emailext \
        --to \"$to\" \
        --cc \"$cc\" \
        --subject \"$subject\" \
        --body \"$body\""

    # Add attachments if provided
    if [ -n "$attachments" ]; then
        command="$command --attachment \"$attachments\""
    fi

    # Execute the email-ext command
    eval $command
}
