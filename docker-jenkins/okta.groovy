#!groovy

// This file try to set SAML as default source for acces control

import jenkins.model.*
import org.jenkinsci.plugins.saml.SamlSecurityRealm
import hudson.security.*

def instance = Jenkins.getInstance()

try {
  TypeOfLogin = System.getenv('TypeOfLogin') ?: "jenkinsDatabase"
  if( "SAML".equals(TypeOfLogin) ){
    def cmd = '''\
      mkdir -p /tmp/secrets/auth/ &&
      aws s3 sync s3://\$SECRETS_BUCKET/ /tmp/secrets/auth/ &&
      aws kms decrypt --region us-east-1 --ciphertext-blob fileb:///tmp/secrets/auth/key.enc --output text --query Plaintext | base64 --decode >> /tmp/secrets/auth/key &&
      gpg --pinentry-mode loopback --no-tty --passphrase-file /tmp/secrets/auth/key --output /tmp/secrets/auth/metadataOkta --decrypt /tmp/secrets/auth/metadataOkta.gpg
    '''

    def sout = new StringBuilder()
    def serr = new StringBuilder()

    def proc = ["bash", "-c", cmd].execute()
    proc.consumeProcessOutput(sout, serr)
    proc.waitFor()

    def idp = new File('/tmp/secrets/auth/metadataOkta').text

    def securityRealm = new SamlSecurityRealm("", idp, "",  "", null, "", null)
    instance.setSecurityRealm(securityRealm)
    instance.save()
  }
} catch (ex) {
  throw ex
} finally {
  def sout = new StringBuilder()
  def serr = new StringBuilder()
  def proc = 'rm -r /tmp/secrets/auth'.execute()
  proc.consumeProcessOutput(sout, serr)
  proc.waitFor()
}
