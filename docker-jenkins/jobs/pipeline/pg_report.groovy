node('jnlp-slave'){

  git credentialsId: 'bitbucket-ssh',branch:'master' , url:'git@bitbucket.org:nclouds/on-call-automation.git'

  content = ""

  dir("reports")
  {
      sh """
        pip install -r requirements.txt
        aws s3 cp s3://$BUCKET/$FILE_NAME report.csv
        """
      FILE_NAME = FILE_NAME.split("/")
      FILE_NAME = FILE_NAME[FILE_NAME.length - 1]
      FILE_NAME = FILE_NAME.replace(".csv","")

      dir("app"){
          sh """
          Xvfb :99 &
          export DISPLAY=:99
          python incidents_pdf.py ${FILE_NAME}
          """
      }
      content = readFile  'general_report.html'
  }
  emailext(to: "otilia.cosma@nclouds.com, braulio@nclouds.com", mimeType: 'text/html', subject: "$FILE_NAME reports", body:  content , attachmentsPattern: 'reports/*.html,reports/*.pdf');

}
