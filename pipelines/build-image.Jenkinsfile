pipeline {
    agent {
        label "Deskspace"
    }

    parameters {
        string(name: 'BRANCH_NAME', description: 'Branche Concerné')
        string(name: 'NAMESPACE', defaultValue: 'test', description: 'Nom du namespace')
        string(name: 'HASH', description: 'Hash du commit')
        string(name: 'HUB_NAMESPACE', defaultValue: 'zlorg', description: 'Le namespace du hub docker pour le dépôt des images')
    }

    environment {
        IMAGE_NAME = ''
    }

    stages {
        stage('Building Image') {
            steps {
                script {
                    IMAGE_NAME = "${params.HUB_NAMESPACE}/${params.BRANCH_NAME}:${params.NAMESPACE}-${params.HASH}"
                    echo "IMAGE TO DEPLOY: [$IMAGE_NAME]"
                }
            }
        }

        stage('Build Docker Image And Push') {
            steps {
                sh """
                    sudo docker build -t $IMAGE_NAME ${params.BRANCH_NAME}
                    sudo docker push $IMAGE_NAME
                    sudo docker rmi $IMAGE_NAME
                """
            }
        }

        stage('Build YAML File') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                build(job: 'Set Kubernetes Image', parameters: [string(name: "IMAGE_NAME", value: "$IMAGE_NAME")])
            }
        }
    }
}
