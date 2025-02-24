cat > "${WORKSPACE}/email_body.html" << EOF
<html>
  <body>
    <p>Month: ${month}</p>
    <p>COF: ${malcodes1[@]}</p>
    <p>BCR: ${malcodes2[@]}</p>
    <p>CRD: ${malcodes3[@]}</p>
    <p>SCC: ${malcodes4[@]}</p>
    <p>UCC: ${malcodes5[@]}</p>
  </body>
</html>
EOF


${FILE,path="email_body.html"}