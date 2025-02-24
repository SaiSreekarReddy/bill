colors=("Red Blue Green")

# Create HTML email content
echo "<html><body><p>" > "${WORKSPACE}/email_body.html"
for word in ${colors[@]}; do
  echo "$word<br>" >> "${WORKSPACE}/email_body.html"
done
echo "</p></body></html>" >> "${WORKSPACE}/email_body.html"