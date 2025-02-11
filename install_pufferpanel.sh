#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Switching to root user...${NC}"
sudo su <<EOF

echo -e "${YELLOW}Updating package list...${NC}"
apt update

echo -e "${GREEN}Creating necessary directories...${NC}"
mkdir -p /var/lib/pufferpanel

echo -e "${GREEN}Creating Docker volume for PufferPanel...${NC}"
docker volume create pufferpanel-config

echo -e "${GREEN}Creating PufferPanel Docker container...${NC}"
docker create --name pufferpanel -p 8080:8080 -p 5657:5657 -v pufferpanel-config:/etc/pufferpanel \
-v /var/lib/pufferpanel:/var/lib/pufferpanel -v /var/run/docker.sock:/var/run/docker.sock \
--restart=on-failure pufferpanel/pufferpanel:latest

echo -e "${GREEN}Starting PufferPanel container...${NC}"
docker start pufferpanel

echo -e "${YELLOW}Creating PufferPanel user...${NC}"
docker exec -it pufferpanel /pufferpanel/pufferpanel user add

echo -e "${GREEN}Installing Ngrok...${NC}"
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list
apt update
apt install -y ngrok

echo -e "${RED}Enter your Ngrok authtoken:${NC}"
read NGROK_AUTH_TOKEN
ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

echo -e "${RED}Enter your Edge command:${NC}"
read EDGE_COMMAND
$EDGE_COMMAND

EOF

echo -e "${GREEN}Installation complete!${NC}"
