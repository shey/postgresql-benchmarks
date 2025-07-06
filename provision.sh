#!/bin/bash

set -e

# --- CONFIG ---
REGION="tor1"
DROPLET_SIZE="s-1vcpu-1gb"
IMAGE="ubuntu-22-04-x64"
SSH_KEY_ID=$(doctl compute ssh-key list --format ID --no-header | head -n1)
TARGET_APP_URL="https://benchmark.shey.ca/"
MASTER_NAME="locust-master"
WORKER_COUNT=8

# --- Create master droplet ---
echo ">>> Creating master droplet..."
doctl compute droplet create $MASTER_NAME \
  --region $REGION \
  --image $IMAGE \
  --size $DROPLET_SIZE \
  --ssh-keys $SSH_KEY_ID \
  --wait

# --- Create worker droplets ---
for i in $(seq 1 $WORKER_COUNT); do
  echo ">>> Creating worker $i..."
  doctl compute droplet create locust-worker-$i \
    --region $REGION \
    --image $IMAGE \
    --size $DROPLET_SIZE \
    --ssh-keys $SSH_KEY_ID \
    --wait
done

# --- Get all IPs ---
echo ">>> Fetching IP addresses..."
MASTER_IP=$(doctl compute droplet get $MASTER_NAME --format PublicIPv4 --no-header)

declare -a WORKER_IPS
for i in $(seq 1 $WORKER_COUNT); do
  ip=$(doctl compute droplet get locust-worker-$i --format PublicIPv4 --no-header)
  WORKER_IPS+=("$ip")
done

echo ">>> Master IP: $MASTER_IP"
echo ">>> Worker IPs:"
printf " - %s\n" "${WORKER_IPS[@]}"

# --- Upload files ---
for ip in $MASTER_IP "${WORKER_IPS[@]}"; do
  echo ">>> Uploading locustfile and setup script to $ip..."
  scp locustfile.py setup_node.sh ubuntu@$ip:~
done

# --- Run master ---
echo ">>> Starting master..."
ssh ubuntu@$MASTER_IP "chmod +x setup_node.sh && ./setup_node.sh master $TARGET_APP_URL" &
sleep 5  # Give it a moment to start

# --- Run workers ---
for ip in "${WORKER_IPS[@]}"; do
  echo ">>> Starting worker on $ip..."
  ssh ubuntu@$ip "chmod +x setup_node.sh && ./setup_locust_node.sh worker $MASTER_IP" &
done

echo ">>> DONE: Locust master is at http://$MASTER_IP:8089"
