#!/bin/bash

# To install new device:
# curl https://install.power.sixfab.com | sudo sh -s TOKEN_HERE
# To fleet deployment mode:
# curl https://install.power.sixfab.com | sudo sh -s -- --fleet FLEET_TOKEN_HERE
# To uninstall power software:
# curl https://install.power.sixfab.com | sudo sh -s -- --uninstall

clear

cat <<"EOF"
    .&@&.             %%          .%@%           
   #@@@%           *&@@@&.         %@@@#         
  &@@&. .&@@%   .%@@@@@%/.   .%@@&. ,&@@%        
 %@@&. /@@@#  *&@@@@&&&@@@@&,  %@@&* .&@@&       
/@@@* .@@@#  &@@&(       (@@@%  #@@&, *@@@*      
%@@&. #@@&. (@@@,         ,&@@( .@@@(  &@@#      
%@@&. #@@&. /@@@,         *&@@( .@@@(  &@@#      
*@@@* .&@@#  %@@@#       %@@@#  #@@&, /@@@,      
 %@@&, *@@@%  .&@@@@@@@@@@@%. .&@@&, ,&@@%       
  %@@&*  %@@#     *#%%%#*     #@@%  *&@@%        
   (@@@&.                         .&@@&/         
     #@#                           #@#    

 _____ _       __      _      ______                      
/  ___(_)     / _|    | |     | ___ \                    
\ `--. ___  _| |_ __ _| |__   | |_/ /____      _____ _ __ 
 `--. \ \ \/ /  _/ _` | '_ \  |  __/ _ \ \ /\ / / _ \ '__|
/\__/ / |>  <| || (_| | |_) | | | | (_) \ V  V /  __/ |   
\____/|_/_/\_\_| \__,_|_.__/  \_|  \___/ \_/\_/ \___|_|   
==========================================================
EOF

print_help() {
  printf "[HELP]  $1\n"
}

print_info() {
  YELLOW='\033[0;33m'
  NC='\033[0m'
  printf "${YELLOW}[INFO]${NC}  $1\n"
}

print_error() {
  RED='\033[0;31m'
  NC='\033[0m'
  printf "${RED}[ERROR]${NC} $1\n"
}

print_done() {
  RED='\033[0;32m'
  NC='\033[0m'
  printf "${RED}[DONE]${NC}  $1\n"
}


help() {
  print_help "Usage:"
  print_help "To install            :  ...commands... [DEVICE_TOKEN]"
  print_help "To fleet-deployment   :  ...commands... --fleet [FLEET_TOKEN]"
  print_help "To uninstall          :  ...commands... --uninstall"
}

if [ "$1" = "--uninstall" ]; then
  print_info "Uninstalling..."

  if [ -d /opt/sixfab/pms ]; then
    print_info "Removing sources..."
    sudo rm -r /opt/sixfab/pms >/dev/null
  fi

  print_info "Removing systemctl services..."

  systemctl status pms_agent > /dev/null 2>&1
  IS_PMS_AGENT_EXIST=$?
  if [ "$IS_PMS_AGENT_EXIST" = "0" ]; then
    sudo systemctl stop pms_agent > /dev/null 2>&1
    sudo systemctl disable pms_agent > /dev/null 2>&1
    sudo rm /etc/systemd/system/pms_agent.service > /dev/null 2>&1
  fi

  systemctl status power_agent > /dev/null 2>&1
  IS_POWER_AGENT_EXIST=$?
  if [ "$IS_POWER_AGENT_EXIST" = "0" ]; then
    sudo systemctl stop power_agent > /dev/null 2>&1
    sudo systemctl disable power_agent > /dev/null 2>&1
    sudo rm /etc/systemd/system/power_agent.service > /dev/null 2>&1
    print_info "Agent service deleted successfully."
  fi

  systemctl status power_request > /dev/null 2>&1
  IS_POWER_REQUEST_EXIST=$?
  if [ "$IS_POWER_REQUEST_EXIST" = "0" ]; then
    sudo systemctl stop power_request > /dev/null 2>&1
    sudo systemctl disable power_request > /dev/null 2>&1
    sudo rm /etc/systemd/system/power_request.service > /dev/null 2>&1
    print_info "Request service deleted successfully."
  fi

  print_done "Sixfab Power Software uninstalled successfully!"
  exit 1
fi

if [ "$1" = "--fleet" ]; then
  if [ -z "$2" ]; then
    print_error "Fleet token is missing"
    help
    exit 1
  else
    TOKEN="$2"
    IS_FLEET_DEPLOY=true
  fi
else
  if [ -z "$1" ]; then
    print_error "Device token is missing"
    help
    exit 1
  else
    TOKEN="$1"
  fi
fi

INTERVAL="10"
AGENT_REPOSITORY="https://git.sixfab.com/sixfab-power/agent.git"
API_REPOSITORY="https://git.sixfab.com/sixfab-power/api.git"

check_distro() {
  OS_DETAILS=$(cat /etc/os-release)
  case "$OS_DETAILS" in
  *Raspbian*)
    :
    ;;
  *)
    read -p "[WARNING] The operations system is not Raspbian,  we are not supporting other operation systems/distros yet. Are you sure to continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
    ;;
  esac
}

update_system() {
  print_info "Updating system package index..."
  sudo apt-get update >/dev/null
}

check_is_user_pi_exists() {
  if [ ! $(id -u pi) ]; then
    print_info 'User pi not exists, creating...'
    sudo adduser --gecos "" pi
    sudo adduser pi sudo
    sudo adduser pi i2c
    sudo adduser pi video
    echo "pi ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

    if id "$1" &>/dev/null; then
      print_info 'User created.'
    else
      print_error "Couldn't create user pi, leaving installer. Run installer as root."
      exit
    fi
  fi
}

create_basefile() {
  print_info ''"Creating Sixfab root directory on /opt..."
  if [ ! -d "/opt/sixfab" ]; then
    sudo mkdir -p /opt/sixfab
    print_info "Root directory created."
  else
    print_info "Directory already exists, skipping."
  fi
}

install_system_dependencies() {
  print_info "Looking for dependencies..."

  # Check if git installed
  if ! [ -x "$(command -v git)" ]; then
    print_info 'Git is not installed, installing...'
    sudo apt-get install git -y >/dev/null
  fi

  # Check if python3 installed
  if ! [ -x "$(command -v python3)" ]; then
    print_info 'Python3 is not installed, installing...'
    sudo apt-get install python3 -y >/dev/null
  fi

  # Check python3 version, minimum python3.6 required
  version=$(python3 -V 2>&1 | grep -Po '(?<=Python )(.+)' | sed -e 's/\.//g')

  if [ "$version" -lt "360" ]; then
    print_error "Python 3.6 or newest version required to run Sixfab Power softwares. Please upgrade Python and re-try. We are suggesting to use latest raspbian version."
    exit
  fi

  # Check if pip3 installed
  if ! [ -x "$(command -v pip3)" ]; then
    print_info 'Pip for python3 is not installed, installing...'
    sudo apt-get install python3-pip -y >/dev/null
  fi

  check_system_dependencies
}

check_system_dependencies() {
  git --version >/dev/null 2>&1
  IS_GIT_INSTALLED=$?
  python3 --version >/dev/null 2>&1
  IS_PYTHON_INSTALLED=$?
  pip3 --version >/dev/null 2>&1
  IS_PIP_INSTALLED=$?
  if [ ! "$IS_GIT_INSTALLED" = "0" ] || [ ! "$IS_PYTHON_INSTALLED" = "0" ] || [ ! "$IS_PIP_INSTALLED" = "0" ]; then
    install_system_dependencies
  fi
}

fleet_deploy() {
  BOARD=$(cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}')

  case $BOARD in
  "900092")
    BOARD="pi_zero"
    ;;
  "900093")
    BOARD="pi_zero"
    ;;
  "9000C1")
    BOARD="pi_zero_w"
    ;;
  "9020e0")
    BOARD="pi_3_a+"
    ;;
  "a02082")
    BOARD="pi_3_b"
    ;;
  "a22082")
    BOARD="pi_3_b"
    ;;
  "a020d3")
    BOARD="pi_3_b+"
    ;;
  "a03111")
    BOARD="pi_4_1gb"
    ;;
  "b03111")
    BOARD="pi_4_2gb"
    ;;
  "c03111")
    BOARD="pi_4_4gb"
    ;;
  "d03114")
    BOARD="pi_4_8gb"
    ;;
  *)
    BOARD="undefined"
    ;;

  esac

  if [ "$BOARD" = "undefined" ]; then
    print_error "Your board is not supported yet."
    exit 1
  fi

  print_info "Board detected: $BOARD"

  API_RESPONSE=$(python3 -c "
import sys
import json
import http.client

conn = http.client.HTTPSConnection('api.power.sixfab.com')

headers = {'Content-type': 'application/json'}
body = json.dumps({
	'board': '$BOARD',
	'uuid': '$TOKEN'
})

conn.request('POST', '/fleet_deploy', body, headers)

response = conn.getresponse()

status_code = response.status

if status_code == 200:
	uuid = json.loads(response.read().decode())['uuid']
else:
	uuid = 'None'
	
response = str(status_code)+','+str(uuid)
sys.exit(response)

" 2>&1 >/dev/null)

  API_CODE=$(echo $API_RESPONSE | cut -d "," -f1)
  API_UUID=$(echo $API_RESPONSE | cut -d "," -f2)

  case $API_CODE in
  404)
    print_error "Fleet not found, please check UUID again."
    exit 1
    ;;
  402)
    print_error "Reached device limit, couldn't create new device."
    exit 1
    ;;
  406)
    print_error "Board/Raspberry Pi version not supported yet."
    exit 1
    ;;
  429)
    print_error "Fleet don't have enough deployment quota."
    exit 1
    ;;
  esac

  TOKEN="$API_UUID"
}

enable_i2c() {
  print_info "Enabling i2c..."
  sudo raspi-config nonint do_i2c 0 >/dev/null
  print_info "I2C enabled."
}

install_agent() {
  if [ ! -d "/opt/sixfab/pms/agent" ]; then
    print_info "Cloning agent source..."
    sudo git clone --quiet $AGENT_REPOSITORY /opt/sixfab/pms/agent
    print_info "Agent source cloned."
  fi

  print_info "Installing agent dependencies from PyPI..."
  sudo pip3 install -r /opt/sixfab/pms/agent/requirements.txt >/dev/null

  if [ -f "/opt/sixfab/.env" ]; then
    sudo sed -i "s/TOKEN=.*/TOKEN=$TOKEN/" /opt/sixfab/.env
    print_info "Environment file exists, updated token."

  else
    print_info "Creating environment file..."
    sudo touch /opt/sixfab/.env

    echo "[pms]
TOKEN=$TOKEN
INTERVAL=$INTERVAL
    " | sudo tee /opt/sixfab/.env > /dev/null 2>&1
    print_info "Environment file created."

  fi
}

install_distribution() {
  if [ -d "/opt/sixfab/pms/api" ]; then
    case $(cd /opt/sixfab/pms/api && sudo git show origin) in
    *sixfab*)
      sudo rm -r /opt/sixfab/pms/api
      ;;
    esac
  fi

  if [ ! -d "/opt/sixfab/pms/api" ]; then
    print_info "Downloading request service..."
    sudo git clone --quiet https://github.com/sixfab/power_distribution-service.git /opt/sixfab/pms/api
    cd /opt/sixfab/pms/api
    pip3 uninstall -y sixfab-power-python-api > /dev/null 2>&1 && sudo pip3 uninstall -y sixfab-power-python-api > /dev/null 2>&1
    sudo pip3 install -r requirements.txt >/dev/null
    print_info "Service downloaded."
  else
    print_info "Updating request service..."
    cd /opt/sixfab/pms/api && sudo git reset --hard HEAD >/dev/null
    cd /opt/sixfab/pms/api && sudo git pull >/dev/null
    sudo pip3 install -r /opt/sixfab/pms/api/requirements.txt >/dev/null
    print_info "Service updated."
  fi
}

initialize_services() {

  if [ ! -f "/etc/systemd/system/power_request.service" ]; then

    print_info "Initializing systemd service for request service..."

    echo "[Unit]
Description=Sixfab UPS HAT Distributed API

[Service]
User=pi
ExecStart=/usr/bin/python3 /opt/sixfab/pms/api/run_server.py

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/power_request.service > /dev/null 2>&1

    print_info "Enabling and starting service."

    sudo systemctl daemon-reload
    sudo systemctl enable power_request > /dev/null 2>&1
    sudo systemctl start power_request

    print_info "Service initialized successfully."

  else
    print_info "Request service already installed, restarting..."
    sudo systemctl restart power_request
  fi

  if [ ! -f "/etc/systemd/system/power_agent.service" ]; then

    print_info "Initializing systemd service for agent..."

    echo "[Unit]
Description=Sixfab PMS Agent
After=network.target network-online.target
Requires=network-online.target

[Service]
ExecStart=/usr/bin/python3 -u agent.py
WorkingDirectory=/opt/sixfab/pms/agent
StandardOutput=inherit
StandardError=inherit
Restart=always
RestartSec=3
User=pi

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/power_agent.service> /dev/null 2>&1

    print_info "Enabling and starting service."

    sudo systemctl daemon-reload
    sudo systemctl enable power_agent > /dev/null 2>&1
    sudo systemctl start power_agent

    print_info "Service initialized successfully."

  else
    print_info "Agent already installed, restarting..."
    sudo systemctl restart power_agent
  fi
}

main() {
  check_distro
  update_system
  check_is_user_pi_exists
  create_basefile
  enable_i2c
  check_system_dependencies

  if [ "$IS_FLEET_DEPLOY" = "true" ]; then
    fleet_deploy
  fi

  install_agent
  install_distribution
  initialize_services

  print_done "Installation complated successfully, connecting to cloud..."
}

main
