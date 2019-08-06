import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import org.jenkinsci.plugins.plaincredentials.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret
import java.util.logging.Logger

Logger logger = Logger.getLogger("jenkins.init.auth")

domain = Domain.global()
store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

try {

  def cmd = '''\
    mkdir -p /tmp/secrets/auth/ &&
    aws s3 sync s3://\$SECRETS_BUCKET/ /tmp/secrets/auth/ &&
    aws kms decrypt --region us-east-1 --ciphertext-blob fileb:///tmp/secrets/auth/key.enc --output text --query Plaintext | base64 --decode >> /tmp/secrets/auth/key &&
    gpg --pinentry-mode loopback --no-tty --passphrase-file /tmp/secrets/auth/key --output /tmp/secrets/auth/slack-token --decrypt /tmp/secrets/auth/slack-token.gpg
    gpg --pinentry-mode loopback --no-tty --passphrase-file /tmp/secrets/auth/key --output /tmp/secrets/auth/bitbucket-ssh --decrypt /tmp/secrets/auth/bitbucket-ssh.gpg
    gpg --pinentry-mode loopback --no-tty --passphrase-file /tmp/secrets/auth/key --output /tmp/secrets/auth/pager-duty --decrypt /tmp/secrets/auth/pager-duty.gpg
    gpg --pinentry-mode loopback --no-tty --passphrase-file /tmp/secrets/auth/key --output /tmp/secrets/auth/bitbucket-credentials --decrypt /tmp/secrets/auth/bitbucket-credentials.gpg
  '''.stripIndent()

  def sout = new StringBuilder()
  def serr = new StringBuilder()

  def proc = ["bash", "-c", cmd].execute()
  proc.consumeProcessOutput(sout, serr)
  proc.waitFor()

  logger.info sout.toString()
  logger.warning serr.toString()

  def slackToken = new File('/tmp/secrets/auth/slack-token').text
  def git_sshkey = new File('/tmp/secrets/auth/bitbucket-ssh').text
  def pagerdutyToken = new File('/tmp/secrets/auth/pager-duty').text
  def bitbucketCredentials = new File('/tmp/secrets/auth/bitbucket-credentials').text

  slackToken = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "slack-token",
    "Token for slack integration",
    Secret.fromString(slackToken)
  )

  privateKey = new BasicSSHUserPrivateKey(
    CredentialsScope.GLOBAL,
    "bitbucket-ssh",
    "Bitbucket SSH",
    new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(git_sshkey),
    "",
    "Bitbucket SSH"
  )
  pagerdutyToken = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "pager-duty",
    "Pagerduty API token",
    Secret.fromString(pagerdutyToken)
  )
  (bitbucketUser, bitbucketPassword) = bitbucketCredentials.tokenize('\n')
  bitbucketCredentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "bitbucket-credentials",
    "Jenkins user for bitbucket",
    bitbucketUser,
    bitbucketPassword
  )

  store.addCredentials(domain, privateKey)
  store.addCredentials(domain, slackToken)
  store.addCredentials(domain, pagerdutyToken)
  store.addCredentials(domain, bitbucketCredentials)

} catch (ex) {
  throw ex
} finally {
  def sout = new StringBuilder()
  def serr = new StringBuilder()
  def proc = 'rm -r /tmp/secrets/auth'.execute()
  proc.consumeProcessOutput(sout, serr)
  proc.waitFor()
}
