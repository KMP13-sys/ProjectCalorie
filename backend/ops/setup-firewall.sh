#!/usr/bin/env bash
# setup-firewall.sh
# Safe UFW firewall setup for a Linux server running this project
# - Requires sudo
# - Allows SSH, HTTP, HTTPS and the app port (default 4000)
# - Sets default policies (deny incoming, allow outgoing)
# - Enables logging and shows status

set -euo pipefail

# All set enviriment variables.
APP_PORT_DEFAULT=4000
SSH_PORT_DEFAULT=22
PORT=4000 
DB_HOST=localhost
DB_USER=root 
DB_PASSWORD=your_database_password_here
DB_NAME=cal-deficits
DB_PORT=3306
SECRET_KEY=your_secret_key_here
JWT_SECRET=secretkey

function echo_err() { echo "[ERROR] $*" >&2; }
function echo_ok() { echo "[OK] $*"; }

if [[ "$EUID" -ne 0 ]]; then
  echo_err "This script must be run with sudo/root. Run: sudo $0"
  exit 2
fi

# Detect ufw
if ! command -v ufw >/dev/null 2>&1; then
  echo_err "ufw not found. Install it first (Ubuntu/Debian: sudo apt update && sudo apt install ufw)"
  exit 3
fi

read -rp "Enter application port to allow (default: ${APP_PORT_DEFAULT}): " APP_PORT
APP_PORT=${APP_PORT:-$APP_PORT_DEFAULT}
read -rp "Enter SSH port to allow (default: ${SSH_PORT_DEFAULT}): " SSH_PORT
SSH_PORT=${SSH_PORT:-$SSH_PORT_DEFAULT}

read -rp "Do you want to allow connections from a management IP / CIDR (e.g. 203.0.113.5/32) to SSH? Leave blank to allow from anywhere: " MGMT_CIDR

# Show planned changes
cat <<EOF
Planned UFW changes:
 - Default incoming: deny
 - Default outgoing: allow
 - Allow SSH port: ${SSH_PORT} ${MGMT_CIDR:+(restricted to ${MGMT_CIDR})}
 - Allow HTTP (80)
 - Allow HTTPS (443)
 - Allow application port: ${APP_PORT}
 - Enable logging and enable UFW

Note: This will NOT open your database port (3306). It's recommended to bind databases to localhost or use private networks.
EOF

read -rp "Proceed? (y/N): " PROCEED
PROCEED=${PROCEED:-N}
if [[ "$PROCEED" != "y" && "$PROCEED" != "Y" ]]; then
  echo "Aborted by user. No changes made."
  exit 0
fi

# Backup existing rules (simple snapshot)
UFW_BACKUP="/root/ufw-before-setup-$(date +%Y%m%d%H%M%S).rules"
ufw status numbered > "$UFW_BACKUP" || true

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (optionally restricted)
if [[ -n "$MGMT_CIDR" ]]; then
  ufw allow from "$MGMT_CIDR" to any port "$SSH_PORT" proto tcp
else
  ufw allow "$SSH_PORT"/tcp
fi

# Allow web
ufw allow 80/tcp
ufw allow 443/tcp

# Allow app port
ufw allow "$APP_PORT"/tcp

# Enable logging (low level to avoid noisy logs; use 'on' for full)
ufw logging low || true

# Enable UFW (will prompt if interactive)
ufw --force enable

# Show final status
ufw status verbose

echo_ok "Firewall setup complete. Backup of previous status saved to: $UFW_BACKUP"

cat <<INFO
Next steps / notes:
 - If you use a cloud provider (AWS/GCP/Azure) also configure Security Groups / Firewall Rules at the provider level to restrict ingress.
 - For Docker: if you run the app inside Docker and publish ports, the host firewall still applies; be sure published ports match the allowed ports.
 - Do NOT open database ports (3306) publicly. Use private networking or SSH tunnel.
INFO
