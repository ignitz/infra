#! /bin/bash

# Update repositores of Ubuntu
apt-get update

# Get own IP of Ec2 instance
SELFIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# Send logs of User data to console in CloudWatch
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

mkdir -p ${HOME}/autostart
chown -R ubuntu:ubuntu ${HOME}/autostart

# Install zsh
apt install zsh -y
chsh -s /bin/zsh ubuntu
su - ubuntu -c "(sh -c $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh))"

# Install tmux and Oh-my-tmux
apt install tmux -y
su - ubuntu -c "(cd ${HOME}/ && git clone https://github.com/gpakosz/.tmux.git && ln -s -f .tmux/.tmux.conf && cp .tmux/.tmux.conf.local .)"

# Install Docker
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt update
apt install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu

# Install Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Portainer
apt install -y apache2-utils && \
docker volume create portainer_data && \
docker run -d -p 8000:8000 -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock --name portainer -v portainer_data:/data portainer/portainer --admin-password="$(htpasswd -nbB ${PORTAINER_USERNAME} ${PORTAINER_PASSWORD} | cut -d ":" -f 2)"

# Install stack
apt install -y awscli unzip && \
mkdir -p /opt/datafeeder/build/ && \
aws s3 cp ${S3_DATAFEEDER_PATH} /opt/datafeeder/build/ && \

(
    cd /opt/datafeeder/ && \
    unzip build/datafeeder.zip && \
    cd datafeeder/ && \
    export POSTGRES_USER=postgres
    export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    export POSTGRES_HOST=postgres
    export SQLSERVER_USER=sa
    export SQLSERVER_PASSWORD=${SQLSERVER_PASSWORD}
    export SQLSERVER_HOST=sqlserver
    export COMPOSE_PROJECT_NAME=datafeeder
    export NODE_PATH=./src
    export TOKEN=${TOKEN}
    # Trick to service wait for databases
    docker-compose -f tests/docker-compose.development.yml up -d sqlserver && \
    docker-compose -f tests/docker-compose.development.yml up -d postgres && \
    echo "Waiting for warm up databases."
    sleep 300 && \
    echo "Starting services." && \
    docker-compose -f tests/docker-compose.development.yml up -d --build && \
    sleep 30 && \
    echo "Creating datafeeder task." && \
    curl --request POST \
    --url http://localhost:3333/api/v1/microservices \
    --header 'authorization: Bearer ${TOKEN}' \
    --header 'content-type: application/json' \
    --data '{
        "intervalms": 1000,
        "nrows": 10,
        "op": "create"
    }'
)

echo "Done"
