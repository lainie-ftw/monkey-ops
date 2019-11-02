
/*************
 * main pipeline: make the chaotic monkey go
 * @Authors Josh Smith & Lainie Vyvyan
 ************/
node('oc-tools'){

    env.OPENSHIFT_URI = ${params.OPENSHIFT_URL}

    def SCM_URL = 'https://github.com/joshmsmith/monkey-ops.git'

    def ocTool = tool "OC"
    env.PATH="${ocTool}:${env.PATH}"

    timestamps {
        try {
            stage('Notify Start') {
                slackSend channel: "${params.SLACK_CHANNEL}", color: 'good', message: ":chaos-monkey::tiara-girl: \n ${env.BUILD_URL}"
            }

            stage('Git Monkey Template') {
                deleteDir() //Wipe the workspace so we are starting completely clean
                timeout(time: 60, unit: 'SECONDS') {
                    git (url: SCM_URL)
                }
            }

            stage('Go Monkey Go') {
                withCredentials([string(credentialsId: params.OPENSHIFT_CLUSTER, variable: 'TOKEN')]) {
                    sh "oc login ${env.OPENSHIFT_URI} --token=${TOKEN}"
                    sh "oc project ${params.PROJECT_NAME}"
                    sh "oc create serviceaccount  monkey-ops -n ${params.PROJECT_NAME}"
                    sh "oc policy add-role-to-user edit system:serviceaccount:${params.PROJECT_NAME}:monkey-ops -n ${params.PROJECT_NAME}"
                    sh "oc create -f ./openshift/monkey-ops-template.yaml -n ${params.PROJECT_NAME}"
                    sh "oc new-app --template=monkey-ops --param=PROJECT_NAME=${params.PROJECT_NAME} --param=APP_NAME=monkey-ops --param=INTERVAL=300 --param=MODE=background --labels=app_name=monkey-ops -n ${params.PROJECT_NAME}"
                }
            }

            stage('Notify Success') {
                slackSend channel: "${params.SLACK_CHANNEL}", color: 'good', message: ":chaos-monkey::success::awwyiss:\n ${env.BUILD_URL} \n :tada::unstoppable:"
            }

        } catch (e) {
            currentBuild.result = "FAILED"
            slackSend channel: "${params.SLACK_CHANNEL}", color: 'danger', message: ":chaos-monkey::facehoof::why: \n ${env.BUILD_URL}console"
            throw e
        }
    }
}
