#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m'


cur_dir=$(pwd)
if [[ $EUID -ne 0 && $(hostname) != "localhost" && $(hostname) != "127.0.0.1" ]]; then
  echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n"
  exit 1
fi

install_jq() {
    if ! command -v jq &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}


menu(){
    install_jq
    clear
    
    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')
    
    # Fetch server isp using ip-api.com
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')

    Docker_CORE=$(check_docker_installed)

    
    echo "+--------------------------------------------------------------------------------------+"
    echo "|  ______  ______         _____    ____    _____  _  __ ______  _____                  |"
    echo "| |  ____||___  /        |  __ \  / __ \  / ____|| |/ /|  ____||  __ \                 |"
    echo "| | |__      / /  ______ | |  | || |  | || |     | ' / | |__   | |__) |  TG CHANNEL    |"
    echo "| |  __|    / /  |______|| |  | || |  | || |     |  <  |  __|  |  _  /  @DVHOST_CLOUD  |"
    echo "| | |____  / /__         | |__| || |__| || |____ | . \ | |____ | | \ \                 |"
    echo "| |______|/_____|        |_____/  \____/  \_____||_|\_\|______||_|  \_\ ( 0.6 )         |"
    echo "+--------------------------------------------------------------------------------------+"
    echo -e "|${GREEN}Server Country    |${NC} $SERVER_COUNTRY"
    echo -e "|${GREEN}Server IP         |${NC} $SERVER_IP"
    echo -e "|${GREEN}Server ISP        |${NC} $SERVER_ISP"
    echo -e "|${GREEN}Server Docker     |${NC} $Docker_CORE"
    echo "+-------------------------------------------------------------------------------+"
    echo -e "|${YELLOW}Please choose an option:${NC}"
    echo "+-------------------------------------------------------------------------------+"
    echo -e $1
    echo "+-------------------------------------------------------------------------------+"
    echo -e "\033[0m"
}


loader(){
    
    menu "| 1  - Install Docker  \n| 2  - Unistall\n| 0  - Exit"
    
    read -p "Enter option number: " choice
    case $choice in
        1)
            install_command
        ;;
        2)
            unistall
        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Not valid"
        ;;
    esac
    
}

install_command(){
    wget https://raw.githubusercontent.com/dev-ir/ez-docker/master/docker-installer.py
    python3 docker-installer.py
}

check_docker_installed() {
  if command -v docker &> /dev/null; then
    echo "Docker is installed."
  else
    echo "Docker is not installed."
  fi
}

unistall(){
    
    echo $'\e[32mUninstalling Docker in 3 seconds... \e[0m' && sleep 1 && echo $'\e[32m2... \e[0m' && sleep 1 && echo $'\e[32m1... \e[0m' && sleep 1 && {
        sudo apt-get purge docker-ce docker-ce-cli containerd.io -y
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
        rm -rf docker-installer.py
        clear
        echo 'Docker Unistalled :(';
    }
    loader
}

loader