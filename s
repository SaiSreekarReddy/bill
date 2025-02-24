# Define arrays
color1=("Red" "Blue" "Green")
color2=("Yellow" "Orange" "Purple")

# Create email HTML file
echo "<html><body>" > "${WORKSPACE}/email_body.html"

# Add Color1 section
echo "<h3>Members of Color1:</h3><ul>" >> "${WORKSPACE}/email_body.html"
for word in "${color1[@]}"; do
  echo "<li>$word</li>" >> "${WORKSPACE}/email_body.html"
done
echo "</ul>" >> "${WORKSPACE}/email_body.html"

# Add Color2 section
echo "<h3>Members of Color2:</h3><ul>" >> "${WORKSPACE}/email_body.html"
for word in "${color2[@]}"; do
  echo "<li>$word</li>" >> "${WORKSPACE}/email_body.html"
done
echo "</ul>" >> "${WORKSPACE}/email_body.html"

echo "</body></html>" >> "${WORKSPACE}/email_body.html"