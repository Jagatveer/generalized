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
jenkinsLocationConfiguration.setUrl('https://jenkins.nclouds/')
jenkinsLocationConfiguration.save()

Jenkins.instance.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false);
Jenkins.instance.save()
