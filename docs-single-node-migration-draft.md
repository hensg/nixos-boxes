# Linux + Ansible migration plan

## Target

Provision a new Debian 13 CX23 as a conventional Linux host managed by Ansible, serve the existing Hugo site through nginx, and run mail through Docker Mailserver Compose. Keep the current NixOS mail and website servers available throughout migration; retire them only after successful cutover and an observation period.

## Why this route

The workload is small and fits the CX23's 2 shared vCPU, 4 GB RAM, and 40 GB disk more naturally without a Kubernetes control plane. Docker Mailserver recommends 2 GB RAM; start with ClamAV disabled and monitor memory. Hugo remains unchanged for this milestone. Its static site build can be produced before deployment, and alternatives can be evaluated later as a separate milestone.

## Repository changes and current state

- `ansible/playbooks/provision-hcloud.yml` manages the Hetzner VPS and firewall with the official `hetzner.hcloud` collection; regular Ansible roles configure Debian and deploy services. The firewall was reconciled and the existing named VPS adopted in place.
- `ansible/` contains the inventory, baseline packages, Docker installation, nginx static-site role, and Docker Mailserver Compose role.
- `mail-web-next` (`2.29.100.110`) is a Debian 13 CX23 with the firewall attached. Its source is the prior isolated Terraform root; preserve its local state as historical recovery material and do not apply Terraform to it.
- Ansible installed baseline security packages, Docker, nginx, the Hugo site, and Docker Mailserver. The site returns HTTP 200 when requested directly at the new IP with the correct host name.
- The mail service has the migrated account/alias configuration, DKIM identity, TLS certificate, and mailbox contents. The Maildir restore matches the source at 1,188 files and 12,668,169 bytes; files are owned by UID/GID 5000. Docker Mailserver is running, IMAPS TLS verifies, and port 25 is reachable from the old VPS.
- The website DNS now points to the new VPS; both `hensg.dev` and `www.hensg.dev` redirect HTTP to HTTPS and return HTTP 200 over HTTPS. The Let’s Encrypt certificate covers both names and expires 14 January 2027. The mail A/AAAA, MX, DKIM, and DMARC records also point to or authenticate the new VPS. The old mail VPS remains running for rollback; a final delta sync could not run because SSH port 22 on the old VPS refuses connections after its disk was unlocked.

## Migration steps

1. [x] Revoke the Hetzner token shared in chat and create a replacement. Confirmed the existing servers are in `hel1`.
2. [x] Use the existing isolated Terraform root once to create the new server and firewall. Preserve its local state; the intended steady-state owner is Ansible.
3. [x] Set up Ansible, configure the new host, deploy Hugo, and stage Docker Mailserver. Direct HTTP preview and IMAPS TLS verify.
4. [x] Reconcile the current Hetzner firewall and adopt the existing server through Ansible. The cloud play disables local `become`; the module masks its API token.
5. [x] Transfer mailbox contents and validate file count/bytes and ownership. The old server remains active, so do one final sync during cutover.
6. [ ] Finish mail cutover validation: update SPF to authorize the new IPv6 address, test end-to-end send/receive and SPF/DKIM/DMARC, and perform a final mailbox sync if SSH is restored on the old VPS.
7. [ ] Verify the new off-server backup/restore path. Keep old servers for rollback during observation; decommission only after successful operation.
8. In milestone 2, evaluate Hugo alternatives and change the site generator only if there is a concrete benefit.

## Remaining prerequisites

- Cloudflare website records (`@` and `www`) and mail A/AAAA records now point to the new VPS. The MX priority 9 target is `mail.hensg.dev`; DKIM and DMARC are present.
- Update the SPF TXT record to authorize both new VPS addresses: `v=spf1 ip4:2.29.100.110 ip6:2a01:4f9:c015:b529::1 include:_spf.google.com ~all`.
- Run an end-to-end mail send/receive test and verify SPF, DKIM, and DMARC results. The old server remains active; its SSH port 22 currently refuses connections, so the final delta sync is pending access recovery.
- Verify an off-server backup and restore for `/srv/mailserver` before decommissioning either original VPS.
- Keep both original servers during validation and the rollback window. The new CX23 is billed during this overlap.
