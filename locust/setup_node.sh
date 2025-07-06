#!/bin/bash

set -e

# --- Usage ---
# ./setup_locust_node.sh master http://your-target-host.com
# ./setup_locust_node.sh worker 192.0.2.10  # master IP

ROLE=$1
TARGET=$2  # host for master mode, master IP for worker mode

if [[ -z "$ROLE" || -z "$TARGET" ]]; then
  echo "Usage:"
  echo "  $0 master https://benchmark.shey.ca"
  echo "  $0 worker master-ip"
  exit 1
fi

# --- System prep ---
echo ">>> Updating and installing dependencies..."
sudo apt update -y
sudo apt install -y python3-pip python3-venv curl unzip

echo ">>> Setting up Python virtualenv..."
python3 -m venv ~/locust-env
source ~/locust-env/bin/activate
pip install --upgrade pip
pip install locust

# --- Raise file descriptor limit ---
echo ">>> Increasing ulimit..."
sudo bash -c 'echo "* soft nofile 65535" >> /etc/security/limits.conf'
sudo bash -c 'echo "* hard nofile 65535" >> /etc/security/limits.conf'
ulimit -n 65535

# --- Download locustfile if not present ---
if [[ ! -f ~/locustfile.py ]]; then
  echo ">>> Downloading placeholder locustfile.py..."
  curl -sSL https://raw.githubusercontent.com/shey/postgresql-benchmarks/refs/heads/main/locust/locustfile.py -o ~/locustfile.py
fi

