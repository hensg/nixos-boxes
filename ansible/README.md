# Hetzner infrastructure and Linux host configuration

Ansible is the single infrastructure workflow: `hetzner.hcloud` manages the Hetzner VPS and firewall, and regular Ansible roles configure Debian and deploy the website/mail services. The current `mail-web-next` VPS is adopted in place; provisioning is name-based and must not rebuild or delete it.

## Provision or reconcile Hetzner resources

Install pinned collections with `ansible-galaxy collection install -r ansible/requirements.yml`. Export the API token as `CODEX_HETZNER` in the environment running Ansible. Then:

```sh
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/provision-hcloud.yml
```

The playbook reconciles only the named firewall, attaches it to the named server, and requests the same server type/image/location/network settings. It does not specify `state: absent`, `state: rebuild`, or any DNS changes. Review the playbook and Hetzner changes before running it.

## Configure services

- `inventory/production/hosts.example.yml` is the inventory template. The ignored local `hosts.yml` points at the current server.
- The static site remains Hugo for this milestone. Build it with the existing site flake and pass the resulting directory as `hugo_build_dir`.
- Mail runs Docker Mailserver with persistent directories on the host. Its credentials, DKIM key, and TLS files are passed as protected local inputs.
- Mailbox contents have been restored. The old server remains live, so perform a final delta sync at cutover before retiring it.
- Public DNS is intentionally unchanged. Change the Cloudflare website origin targets and the DNS-only mail A/AAAA records only after you are ready to cut over.

Keep the old Terraform files and local state as historical recovery material. Ansible now reconciles the VPS and firewall; do not run Terraform against this VPS.
