Firewall setup helper

This folder contains a small helper script to configure a basic host firewall using UFW (Ubuntu/Debian-friendly).

Files
- setup-firewall.sh — idempotent-ish script to set UFW defaults, allow SSH/HTTP/HTTPS and your application port. Requires sudo.

Usage
1. SSH to your server where this backend runs.
2. Copy or pull the repo on the server and run:

```bash
cd /path/to/repo/backend/ops
sudo bash setup-firewall.sh
```

3. Follow prompts: enter your app port (default 4000), optionally restrict SSH to a management IP/CIDR, then confirm.

Cloud provider notes
- If you deploy to cloud VMs (EC2/GCE/Azure VM), also configure the provider-level firewalls / security groups — these operate in addition to the instance firewall.
- For container platforms (ECS, Kubernetes), prefer network policies / security groups at the platform level instead of relying solely on host firewall.

Security recommendations
- Keep database ports closed publically and only accessible via private networks or SSH tunnels.
- Consider automating ufw setup in your infrastructure provisioning (e.g., cloud-init, Terraform, or an Ansible role) rather than manual runs.

