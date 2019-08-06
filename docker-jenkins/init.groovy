#!groovy
import jenkins.*
import jenkins.model.*
import hudson.model.*
import hudson.security.*
import java.util.logging.Logger
import jenkins.security.s2m.*

Logger logger = Logger.getLogger("jenkins.init.init")

def instance = Jenkins.getInstance()
def jenkins_username
def jenkins_password

try {

  def cmd = '''\
    mkdir -p /tmp/secrets/init/ &&
    aws s3 sync s3://\$SECRETS_BUCKET/ /tmp/secrets/init/ &&
    aws kms decrypt --region us-east-1 --ciphertext-blob fileb:///tmp/secrets/init/key.enc --output text --query Plaintext | base64 --decode >> /tmp/secrets/init/key &&
    gpg --pinentry-mode loopback --no-tty --passphrase-file /tmp/secrets/init/key --output /tmp/secrets/init/jenkins-auth --decrypt /tmp/secrets/init/jenkins-auth.gpg
  '''

  def sout = new StringBuilder()
  def serr = new StringBuilder()

  def proc = ["bash", "-c", cmd].execute()
  proc.consumeProcessOutput(sout, serr)
  proc.waitFor()

  logger.info sout.toString()
  logger.warning serr.toString()

  (jenkins_username, jenkins_password) = new File('/tmp/secrets/init/jenkins-auth').text.tokenize('\n')

} catch (ex) {
  throw ex
} finally {
  def sout = new StringBuilder()
  def serr = new StringBuilder()
  def proc = 'rm -r /tmp/secrets/init'.execute()
  proc.consumeProcessOutput(sout, serr)
  proc.waitFor()

  jenkins_username = jenkins_username ?: "admin"
  jenkins_password = jenkins_password ?: "admin"

  def hudsonRealm = new HudsonPrivateSecurityRealm(false)
  hudsonRealm.createAccount(jenkins_username,jenkins_password)
  instance.setSecurityRealm(hudsonRealm)

  def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
  strategy.setAllowAnonymousRead(false)
  instance.setAuthorizationStrategy(strategy)
  instance.save()

  def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
  jenkinsLocationConfiguration.setAdminAddress("noreply@jenkins.nclouds.com")
  jenkinsLocationConfiguration.setUrl('https://jenkins.nops.io/')
  jenkinsLocationConfiguration.save()

  Jenkins.instance.injector.getInstance(AdminWhitelistRule.class)
    .setMasterKillSwitch(false);
  Jenkins.instance.save()

}
