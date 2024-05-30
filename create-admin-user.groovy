import jenkins.model.*
import hudson.security.*

println "--> creating admin user"
def adminUsername = System.getenv("JENKINS_ADMIN_USERNAME")
def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD")
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(strategy)
Jenkins.instance.save()
