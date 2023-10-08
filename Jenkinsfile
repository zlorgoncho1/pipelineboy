pipeline {
    agent {
        label "Deskspace"
    }

    stages {
        stage('BUILD HELLO-BACKEND MICRO-SERVICE') {
            steps {
                script {
                    build(job: 'Build Image', parameters: [
                       string(name: 'BRANCH_NAME', value: env.BRANCH_NAME),
                       string(name: 'HASH', value: env.GIT_COMMIT),
                    ])
                }
            }
        }
    }
}
