#!groovy

// This file configure the Global Slack Notifier Settings

import jenkins.model.*

def slack = Jenkins.getInstance().getExtensionList(jenkins.plugins.slack.SlackNotifier.DescriptorImpl.class)[0]

try {

  def cmd = '''\
    mkdir -p /tmp/secrets/auth/ &&
    aws s3 sync s3://\$SECRETS_BUCKET/ /tmp/secrets/auth/ &&
    aws kms decrypt --region us-east-1 --ciphertext-blob fileb:///tmp/secrets/auth/key.enc --output text --query Plaintext | base64 --decode >> /tmp/secrets/auth/key &&
    gpg --pinentry-mode loopback --no-tty --passphrase-file /tmp/secrets/auth/key --output /tmp/secrets/auth/slack-token --decrypt /tmp/secrets/auth/slack-token.gpg
  '''

  def sout = new StringBuilder()
  def serr = new StringBuilder()

  def proc = ["bash", "-c", cmd].execute()
  proc.consumeProcessOutput(sout, serr)
  proc.waitFor()

  def slackToken = new File('/tmp/secrets/auth/slack-token').text

  def params = [
    slackTeamDomain: "nclouds",
    slackToken: slackToken,
    slackRoom: "ken-dev",
    slackBuildServerUrl: "https://jenkins.nops.io/",
    slackSendAs: ""
  ]

  def req = [
    getParameter: { name -> params[name] }
  ] as org.kohsuke.stapler.StaplerRequest
  slack.configure(req, null)

  slack.save()

} catch (ex) {
  throw ex
} finally {
  def sout = new StringBuilder()
  def serr = new StringBuilder()
  def proc = 'rm -r /tmp/secrets/auth'.execute()
  proc.consumeProcessOutput(sout, serr)
  proc.waitFor()
}
