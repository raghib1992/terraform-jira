import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import java.net.URLEncoder
import org.apache.commons.codec.digest.DigestUtils

def defaultRolePermissions = [
        siemIntegrations           : [get: false, update: false, create: false, delete: false],
        sharingConfig              : [get: false, update: false],
        memberRoles                : [get: false, clone: false, update: false, create: false, delete: false],
        identityPolicyGroups       : [get: false, update: false, delete: false, assignAll: false, assign: false],
        roles                      : [get: false, clone: false, update: false, create: false, delete: false],
        circles                    : [get: false, update: false, create: false, cleanupAllFiles: false, delete: false, confirmDelete: false],
        fileHashes                 : [get: false, update: false, create: false, delete: false],
        sharingPolicies            : [get: false, update: false, create: false, delete: false],
        shares                     : [updateFiles: false, reactivate: false, get: false, update: false, updateParticipants: false],
        bjIntegrations             : [get: false, downloadSpif: false, update: false, create: false, delete: false],
        bjSelectors                : [get: false],
        members                    : [reinvite: false, get: false, update: false, invite: false, delete: false],
        identityPolicies           : [get: false, update: false, create: false, delete: false],
        mailSettings               : [get: false, save: false, validate: false],
        keyManagementPolicies      : [get: false, update: false, create: false, delete: false],
        logs                       : [startRecording: false, get: false, getStatus: false, stopRecording: false],
        sharedFiles                : [get: false, update: false],
        applicationProtections     : [get: false, update: false, create: false, delete: false, getUnusedApplicationGroups: false],
        endpoints                  : [get: false, update: false, delete: false],
        identityProviders          : [get: false, refreshExternally: false, refresh: false, update: false, create: false, createExternally: false, delete: false, validate: false],
        rootEndpoints              : [confirm: false, confirmAll: false, get: false, update: false, delete: false],
        applicationGroups          : [get: false],
        profile                    : [update: false, changePassword: false],
        groups                     : [get: false, update: false, create: false, delete: false],
        firewallPolicies           : [get: false, update: false, create: false, delete: false],
        users                      : [get: false, update: false, create: false, delete: false],
        applicationsConfig         : [get: false, update: false],
        clientConfigurationPolicies: [get: false, update: false, create: false, delete: false],
        bjRules                    : [get: false, update: false, create: false, delete: false],
        identityProviderGroups     : [get: false],
        administrative             : [deleteIdentityProvider: false, createIdentityProvider: false, getIdentityProvider: false],
        files                      : [get: false, update: false, delete: false],
        rootMembers                : [get: false, update: false, invite: false, delete: false],
        sharedEndpoints            : [get: false, update: false, delete: false],
        keyProviders               : [get: false, update: false, create: false, delete: false],
        unconfirmedEndpoints       : [confirm: false, confirmAllInCircle: false, get: false, delete: false],
        applications               : [get: false, update: false, delete: false]
]

def getLoginCookie(String username, String password, String server) {
    username = URLEncoder.encode(username, 'UTF-8')
    password = URLEncoder.encode(password, 'UTF-8')
    echo "Sending form data to /web/login..."
    def response = httpRequest acceptType: 'NOT_SET',
            consoleLogResponseBody: false, // This API does not have a response
            contentType: 'APPLICATION_FORM',
            httpMode: 'POST',
            requestBody: "anchor=&username=${username}&password=${password}",
            timeout: 10,
            url: "https://${server}/web/login",
            validResponseCodes: '200:399'
    def cookie
    try {
        cookie = response.headers.get('Set-Cookie')[0]
    } catch (java.lang.NullPointerException e) {
        echo "Caught exception: ${e}"
        error('Could not get cookie from login.')
    } catch (Exception e) {
        echo "Caught unhandled exception: ${e}"
        throw e
    }
    return cookie
}

def createAdminRole(outputJson, loginCookie, roleName) {
    def body = JsonOutput.toJson([[name: roleName]])
    echo "Sending JSON to /api/v2/roles/create:\n${body}"
    def response = httpRequest acceptType: 'APPLICATION_JSON',
            consoleLogResponseBody: false,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'Cookie', value: loginCookie]],
            httpMode: 'POST',
            requestBody: body,
            timeout: 10,
            url: "https://${outputJson.hostname.value}/api/v2/roles/create",
            validResponseCodes: '200:299'
    responseJson = new JsonSlurper().parseText(response.content)
    def roleId = responseJson.data.itemId.get(0)
    echo "Received role ID from response: ${roleId}"
    return roleId
}

def getAdminRoleId(outputJson, loginCookie, roleName) {
    def body = JsonOutput.toJson([
            from    : 0,
            limit   : 1,
            orderBy : "name-asc",
            searchBy: "(name LIKE '${roleName}')"
    ])
    echo "Sending JSON to /api/v2/roles/get:\n${body}"
    def response = httpRequest acceptType: 'APPLICATION_JSON',
            consoleLogResponseBody: true,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'Cookie', value: loginCookie]],
            httpMode: 'POST',
            requestBody: body,
            timeout: 10,
            url: "https://${outputJson.hostname.value}/api/v2/roles/get",
            validResponseCodes: '200:299'
    responseJson = new JsonSlurper().parseText(response.content)
    def roleId = responseJson.items.itemId.get(0)
    echo "Received role ID from response: ${roleId}"
    return roleId
}

def updateAdminRole(outputJson, loginCookie, roleId, roleName, permissions) {
    def body = JsonOutput.toJson([[
                                          itemId     : roleId,
                                          name       : roleName,
                                          permissions: permissions
                                  ]])
    httpRequest acceptType: 'APPLICATION_JSON',
            consoleLogResponseBody: false,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'Cookie', value: loginCookie]],
            httpMode: 'POST',
            requestBody: body,
            timeout: 10,
            url: "https://${outputJson.hostname.value}/api/v2/roles/update",
            validResponseCodes: '200:299'
}

def createAdminGroup(outputJson, loginCookie, roleId, groupName) {
    def body = JsonOutput.toJson([[
                                          name      : groupName,
                                          roleItemId: roleId
                                  ]])
    echo "Sending JSON to /api/v2/groups/create:\n${body}"
    def response = httpRequest acceptType: 'APPLICATION_JSON',
            consoleLogResponseBody: true,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'Cookie', value: loginCookie]],
            httpMode: 'POST',
            requestBody: body,
            timeout: 10,
            url: "https://${outputJson.hostname.value}/api/v2/groups/create",
            validResponseCodes: '200:299'
    responseJson = new JsonSlurper().parseText(response.content)
    def groupId = responseJson.data.itemId.get(0)
    echo "Received group ID from response: ${groupId}"
    return groupId
}

def createAdminUser(outputJson, loginCookie, email, groupId, name, password) {
    def body = JsonOutput.toJson([[
                                          active     : true,
                                          email      : email,
                                          groupItemId: groupId,
                                          name       : name,
                                          password   : password
                                  ]])
    echo "Sending JSON to /api/v2/users/create..."
    def response = httpRequest acceptType: 'APPLICATION_JSON',
            consoleLogResponseBody: true,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'Cookie', value: loginCookie]],
            httpMode: 'POST',
            requestBody: body,
            timeout: 10,
            url: "https://${outputJson.hostname.value}/api/v2/users/create",
            validResponseCodes: '200:299'
}

def setAdminPassword(outputJson, loginCookie, oldPassword, newPassword) {
    def body = JsonOutput.toJson([oldPassword: oldPassword, newPassword: newPassword])
    httpRequest acceptType: 'APPLICATION_JSON',
            consoleLogResponseBody: true,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'Cookie', value: loginCookie]],
            httpMode: 'POST',
            requestBody: body,
            timeout: 10,
            url: "https://${outputJson.hostname.value}/api/changePassword",
            validResponseCodes: '200:299'
}

def setMailSettings(outputJson, loginCookie) {
    def body = JsonOutput.toJson([
            from    : "${outputJson.'ses-iam-user-from-address'.value}",
            host    : 'email-smtp.us-west-2.amazonaws.com',
            password: "${outputJson.'ses-iam-user-smtp-password'.value}",
            port    : 587,
            security: 'tls',
            username: "${outputJson.'ses-iam-user-smtp-username'.value}"
    ])
    httpRequest acceptType: 'APPLICATION_JSON',
            consoleLogResponseBody: false,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'Cookie', value: loginCookie]],
            httpMode: 'POST',
            requestBody: body,
            timeout: 10,
            url: "https://${outputJson.hostname.value}/api/v2/mailSettings/save",
            validResponseCodes: '200:299'
}

def endPipeline(String message = 'No reason') {
    echo "Ending pipeline: ${message}"
    currentBuild.getRawBuild().getExecutor().interrupt(Result.SUCCESS)
    sleep(5) // Interrupt is not blocking and does not take effect immediately.
}

def anyChangesExceptLambdaDbProvisioner(planJson) {
    return planJson.resource_changes.findAll {
        !it.change.actions.contains('no-op') &&
                !it.change.actions.contains('read') &&
                (it.address != 'null_resource.lambda-db-provisioner')
    }
}

def resourceCreated(planJson, String resourceAddress) {
    return planJson.resource_changes.findAll {
        it.change.actions.contains('create') &&
                (it.address == resourceAddress)
    }
}


def agentUploadEnabled = false
def changedLaunchTemplate = false
def changedAutoScalingGroup = false
def changedSesIamUserKey = false
def freshDeployment = false
def freshDeploymentPassword = null
def smtpAdminPassword = null
def applyOutputJson = null
def jenkinsProps = null
def terraformVars = null

pipeline {
    agent none
    options {
        timestamps()
    }
    parameters {
        booleanParam name: 'END_IF_NO_CHANGES', defaultValue: true,
                description: 'End pipeline after "Plan" stage if no changes are detected'
        booleanParam name: 'SET_ADMIN_PASSWORD', defaultValue: false,
                description: 'Set admin password after fresh deployment'
        string name: 'DEFAULT_ADMIN_PASSWORD', defaultValue: 'Password#1',
                description: 'Admin password will be changed from this if SET_ADMIN_PASSWORD'
        booleanParam name: 'CREATE_SMTP_ADMIN', defaultValue: false,
                description: 'Create SMTP admin after fresh deployment'
        string name: 'CURRENT_ADMIN_PASSWORD', defaultValue: '',
                description: 'SMTP admin will be created with this password'
        booleanParam name: 'UPDATE_SMTP_CREDENTIALS', defaultValue: false,
                description: 'Force update of SMTP credentials'
    }
    stages {
        stage('Terraform') {
            agent {
                label "saas-deploy"
            }
            environment {
                TF_LOG = 'INFO'
                TF_IN_AUTOMATION = 'true'
                TF_INPUT = 'false'
                TF_CLI_ARGS = '-no-color'
            }
            stages {
                stage('Initialize') {
                    environment {
                        TF_LOG_PATH = './init.tf.log'
                    }
                    steps {
                        script {
                            if (fileExists('Jenkins.props')) {
                                echo 'Parsing Jenkins properties'
                                jenkinsProps = readProperties file: 'Jenkins.props'
                            }
                            if (!fileExists('terraform.tfvars')) {
                                currentBuild.result = 'FAILURE'
                                error('This branch does not have a terraform.tfvars file!')
                            }
                            echo 'Parsing terraform variables'
                            terraformVars = readProperties file: 'terraform.tfvars'
                            agentUploadEnabled = terraformVars.agent_upload_enabled
                            def hostname = DigestUtils.sha256Hex("${terraformVars.name_prefix.replaceAll('"', '')}:ponyo")
                                    .reverse().take(10).reverse()
                            smtpAdminPassword = DigestUtils.sha256Hex("${terraformVars.name_prefix.replaceAll('"', '')}:sosuke")
                                    .reverse().take(10).reverse()
                                    .replaceFirst(/[a-z]/, 'A') + '#1'
                            if (!smtpAdminPassword.matches('.*[a-z].*')) {
                                smtpAdminPassword = "a${smtpAdminPassword}"
                            }
                            if (!smtpAdminPassword.matches('.*[A-Z].*')) {
                                smtpAdminPassword = "${smtpAdminPassword}A"
                            }
                            def buildDescription = "${terraformVars.name_prefix}" +
                                    " - ${hostname}.${terraformVars.domainname}" +
                                    " - (${terraformVars.region})"
                            buildDescription = buildDescription.replace('"', '') // it's not really a props file
                            currentBuild.description = buildDescription
                            tee('tf_init.log') {
                                sh "terraform init --reconfigure --backend-config key=sc-saas/${terraformVars.name_prefix}"
                            }
                        }
                    }
                }
                stage('Stage agents') {
                    when {
                        allOf {
                            expression { jenkinsProps }
                            expression { agentUploadEnabled }
                        }
                    }
                    steps {
                        script {
                            if (jenkinsProps.ANDROID_JOB_NAME && jenkinsProps.ANDROID_BUILD_NUMBER) {
                                dir('agents/android') {
                                    copyArtifacts fingerprintArtifacts: true,
                                            projectName: jenkinsProps.ANDROID_JOB_NAME,
                                            selector: specific(jenkinsProps.ANDROID_BUILD_NUMBER),
                                            filter: jenkinsProps.ANDROID_ARTIFACT_FILTER ?: 'app-release.apk'
                                    sh 'mv app-release.apk fhfs.apk'
                                }
                            }
                            if (jenkinsProps.LINUX_JOB_NAME && jenkinsProps.LINUX_BUILD_NUMBER) {
                                dir('agents/linux') {
                                    copyArtifacts fingerprintArtifacts: true,
                                            projectName: jenkinsProps.LINUX_JOB_NAME,
                                            selector: specific(jenkinsProps.LINUX_BUILD_NUMBER),
                                            filter: jenkinsProps.LINUX_ARTIFACT_FILTER ?: 'fhfs.run'
                                }
                            }
                            if (jenkinsProps.MAC_JOB_NAME && jenkinsProps.MAC_BUILD_NUMBER) {
                                dir('agents/mac') {
                                    copyArtifacts fingerprintArtifacts: true,
                                            projectName: jenkinsProps.MAC_JOB_NAME,
                                            selector: specific(jenkinsProps.MAC_BUILD_NUMBER),
                                            flatten: true,
                                            filter: jenkinsProps.MAC_ARTIFACT_FILTER ?:
                                                    "**/bundle-*.${jenkinsProps.MAC_BUILD_NUMBER}.tar.gz" +
                                                            ", **/SecureCircle-*.${jenkinsProps.MAC_BUILD_NUMBER}.pkg"
                                    sh "mv bundle-*.${jenkinsProps.MAC_BUILD_NUMBER}.tar.gz resources/bundle.dat"
                                    sh "mv SecureCircle-*.${jenkinsProps.MAC_BUILD_NUMBER}.pkg fhfs.pkg"
                                }
                            }
                            if (jenkinsProps.WIN_JOB_NAME && jenkinsProps.WIN_BUILD_NUMBER) {
                                dir('agents/win') {
                                    copyArtifacts fingerprintArtifacts: true,
                                            projectName: jenkinsProps.WIN_JOB_NAME,
                                            selector: specific(jenkinsProps.WIN_BUILD_NUMBER),
                                            flatten: true,
                                            filter: jenkinsProps.WIN_ARTIFACT_FILTER ?: '**/fhfs.exe, **/fhfs-tikajre.exe'
                                    sh 'mv fhfs-tikajre.exe resources/bundle.dat || true'
                                }
                            }
                        }
                    }
                }
                stage('Plan') {
                    environment {
                        TF_LOG_PATH = './plan.tf.log'
                    }
                    steps {
                        tee('plan.log') {
                            sh 'terraform plan -out=plan.out'
                        }
                        sh 'terraform show -json plan.out > plan.json'
                        echo 'Parsing json output for changes'
                        script {
                            def planJson = readJSON file: 'plan.json'
                            if (!anyChangesExceptLambdaDbProvisioner(planJson) && params.END_IF_NO_CHANGES) {
                                endPipeline('No changes detected')
                            }
                            if (resourceCreated(planJson, 'aws_db_instance.scdb')) {
                                freshDeployment = true
                            }
                            planJson.resource_changes.findAll { !it.change.actions.contains('no-op') }.each {
                                switch (it.type) {
                                    case 'aws_launch_template':
                                        echo 'Detected launch template change'
                                        changedLaunchTemplate = true
                                        break
                                    case 'aws_autoscaling_group':
                                        echo 'Detected auto-scaling group change'
                                        changedAutoScalingGroup = true
                                        break
                                    case 'aws_iam_access_key':
                                        if (it.name == 'ses-iam-user-key') {
                                            echo 'Detected SES IAM key change'
                                            changedSesIamUserKey = true
                                        }
                                        break
                                    default: break
                                }
                            }
                        }
                        input 'Approve plan?'
                    }
                }
                stage('Apply') {
                    environment {
                        TF_LOG_PATH = './apply.tf.log'
                    }
                    input {
                        message 'Apply configuration?'
                    }
                    steps {
                        tee('apply.log') {
                            sh 'terraform apply -auto-approve plan.out'
                        }
                        sh 'terraform output -json > output.json'
                        echo 'Parsing json output for output'
                        script {
                            applyOutputJson = readJSON file: 'output.json'
                            echo applyOutputJson.hostname.value
                        }
                    }
                }
                stage('Set Administrative Password') {
                    when {
                        anyOf {
                            expression { freshDeployment }
                            expression { params.SET_ADMIN_PASSWORD }
                        }
                    }
                    steps {
                        script {
                            freshDeploymentPassword = UUID.randomUUID().toString().replaceFirst(/[a-z]/, 'A') + '#1'
                            def loginCookie
                            tee('change-admin-pass.log') {
                                // On fresh deployment these could fail
                                timeout(10) {
                                    waitUntil {
                                        try {
                                            loginCookie = getLoginCookie('admin@securecircle.com',
                                                    params.DEFAULT_ADMIN_PASSWORD, applyOutputJson.hostname.value)
                                            return true
                                        } catch (Exception e) {
                                            echo "Caught unhandled exception: ${e}"
                                            return false
                                        }
                                    }
                                }
                                timeout(10) {
                                    waitUntil {
                                        try {
                                            setAdminPassword(applyOutputJson, loginCookie,
                                                    params.DEFAULT_ADMIN_PASSWORD, freshDeploymentPassword)
                                            return true
                                        } catch (Exception e) {
                                            echo "Caught unhandled exception: ${e}"
                                            return false
                                        }
                                    }
                                }
                                echo "Password for admin@securecircle.com has been set to: ${freshDeploymentPassword}"
                            }
                        }
                    }
                }
                stage('SMTP Configuration') {
                    stages {
                        stage('Create SMTP admin') {
                            when {
                                anyOf {
                                    expression { freshDeployment }
                                    allOf {
                                        expression { params.CREATE_SMTP_ADMIN }
                                        expression { params.CURRENT_ADMIN_PASSWORD?.trim() }
                                    }
                                }
                            }
                            steps {
                                script {
                                    tee('create-smtp-admin.log') {
                                        def adminPassword
                                        if (freshDeployment) {
                                            adminPassword = freshDeploymentPassword
                                        } else {
                                            adminPassword = params.CURRENT_ADMIN_PASSWORD
                                        }
                                        def loginCookie = getLoginCookie('admin@securecircle.com',
                                                adminPassword, applyOutputJson.hostname.value)
                                        def roleId = createAdminRole(applyOutputJson, loginCookie,
                                                'SMTP Update (Managed)')
                                        def permissions = defaultRolePermissions
                                        permissions.mailSettings.save = true
                                        updateAdminRole(applyOutputJson, loginCookie, roleId, 'SMTP Update (Managed)',
                                                permissions)
                                        def groupId = createAdminGroup(applyOutputJson, loginCookie, roleId,
                                                'SMTP Update (Managed)')
                                        createAdminUser(applyOutputJson, loginCookie,
                                                "saas+${terraformVars.name_prefix.replaceAll('"', '')}@securecircle.com", groupId,
                                                'SMTP Update (Managed)', smtpAdminPassword)
                                    }
                                }
                            }
                        }
                        stage('Update SMTP Credentials') {
                            when {
                                anyOf {
                                    expression { changedSesIamUserKey }
                                    expression { freshDeployment }
                                    expression { params.UPDATE_SMTP_CREDENTIALS }
                                }
                            }
                            steps {
                                script {
                                    catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                        tee('update-stmp.log') {
                                            def loginCookie = getLoginCookie(
                                                    "saas+${terraformVars.name_prefix.replaceAll('"', '')}@securecircle.com",
                                                    smtpAdminPassword, applyOutputJson.hostname.value
                                            )
                                            setMailSettings(applyOutputJson, loginCookie)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                stage('Update ASG') {
                    when {
                        beforeInput true
                        allOf {
                            expression { changedLaunchTemplate }
                            expression { !changedAutoScalingGroup }
                        }
                    }
                    input {
                        message 'Launch template change detected, update auto-scaling group?'
                    }
                    stages {
                        stage('Taint') {
                            environment {
                                TF_LOG_PATH = './taint.tf.log'
                            }
                            steps {
                                tee('taint.log') {
                                    sh 'terraform taint aws_autoscaling_group.mumbai-ec2-asg'
                                }
                            }
                        }
                        stage('Plan') {
                            environment {
                                TF_LOG_PATH = './taint.plan.tf.log'
                            }
                            steps {
                                tee('taint.plan.log') {
                                    sh 'terraform plan -target aws_autoscaling_group.mumbai-ec2-asg -out=taint.plan.out'
                                }
                                sh 'terraform show -json taint.plan.out > taint.plan.json'
                                echo 'Parsing json output for changes'
                                script {
                                    def planJson = readJSON file: 'taint.plan.json'
                                    if (!anyChangesExceptLambdaDbProvisioner(planJson)) {
                                        error("No changes detected. This shouldn't happen!")
                                    }
                                }
                            }
                            post { success { input 'Approve plan?' } }
                        }
                        stage('Apply') {
                            environment {
                                TF_LOG_PATH = './taint.apply.tf.log'
                            }
                            input { message 'Apply configuration?' }
                            steps {
                                tee('taint.apply.log') {
                                    sh 'terraform apply -target aws_autoscaling_group.mumbai-ec2-asg -auto-approve taint.plan.out'
                                }
                                sh 'terraform output -json > taint.output.json'
                                echo 'Parsing json output for output'
                                script {
                                    def outputJson = readJSON file: 'taint.output.json'
                                    echo outputJson.hostname.value
                                }
                            }
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '*plan.out, *plan.json, *output.json, *.log',
                            onlyIfSuccessful: false, allowEmptyArchive: true
                }
            }
        }
    }
}
