pipeline {
    agent {
        label "Deskspace"
    }

    parameters {
        string(name: 'IMAGE_NAME', description: 'Nom complet de l\'image') // exemple: 'zlorg/hello-backend:test-uygjdhfyt656tfuddyt'
    }

    environment {
        CONTAINER_NAME = ''
        YAML_PATH = ''
    }

    stages {
        stage('Extraction des informations de l\'image') {
            steps {
                script {
                    def beforeTag = params.IMAGE_NAME.split(":")[0]
                    def parts = beforeTag.split("/")
                    env.CONTAINER_NAME = parts.size() > 1 ? parts[1] : ''
                    def tagPart = params.IMAGE_NAME.split(":")[1]
                    def namespace = tagPart.split("-")[0]
                    env.YAML_PATH = "iac/kubernetes/${namespace}/${env.CONTAINER_NAME}.yaml"
                }
                echo "CONTAINER_NAME: ${env.CONTAINER_NAME}"
                echo "YAML_PATH: ${env.YAML_PATH}"
            }
        }

        stage('Pull Git Repository') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "iac"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[url: 'https://github.com/zlorgoncho1/pipelineboy']]
                ])
            }
        }

        stage('Mise à jour du fichier YAML correspondant') {
            steps {
                script {
                    sh """
                        sudo yq -i '.spec.template.spec.containers[] | select(.name == "${env.CONTAINER_NAME}").image = "${params.IMAGE_NAME}"' ${env.YAML_PATH}
                    """
                }
            }
        }

        stage('Push Changes to Repository') {
            steps {
                script {
                    sh """
                        git add ${env.YAML_PATH}
                        git commit -m "[JENKINS | KUBERNETES | IMAGE UPDATE] - ${env.YAML_PATH} -> ${env.CONTAINER_NAME}: [${params.IMAGE_NAME}]"
                        git push
                    """
                }
            }
        }
    }
}
