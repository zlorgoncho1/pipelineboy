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
                    CONTAINER_NAME = parts[1]
                    def tagPart = params.IMAGE_NAME.split(":")[1]
                    def namespace = tagPart.split("-")[0]
                    YAML_PATH = "iac/kubernetes/${namespace}/${env.CONTAINER_NAME}.yaml"
                    echo "CONTAINER_NAME: ${env.CONTAINER_NAME}"
                    echo "YAML_PATH: ${env.YAML_PATH}"
                }
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
                        yq -i '.spec.template.spec.containers[] | select(.name == "$CONTAINER_NAME").image = "${params.IMAGE_NAME}"' $YAML_PATH
                    """
                }
            }
        }

        stage('Push Changes to Repository') {
            steps {
                script {
                    sh """
                        git add $YAML_PATH
                        git commit -m "[JENKINS | KUBERNETES | IMAGE UPDATE] - $YAML_PATH -> $CONTAINER_NAME: [${params.IMAGE_NAME}]"
                        git push
                    """
                }
            }
        }
    }
}
