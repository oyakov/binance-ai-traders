# Incident Response Guide for Binance AI Traders

## Overview

This document provides comprehensive procedures for responding to security incidents in the binance-ai-traders platform. The guide follows industry best practices and ensures rapid, effective response to security events.

## Incident Classification

### Severity Levels

**CRITICAL (P0) - Immediate Response Required**
- Data breach or exposure of sensitive data (API keys, passwords, customer data)
- Unauthorized access to production systems
- Complete service outage affecting trading operations
- Ransomware or malware infection
- Active exploitation of vulnerability
- Financial loss or fraudulent trading activity

**HIGH (P1) - Response Within 1 Hour**
- Attempted unauthorized access (failed but repeated)
- Suspected compromise of non-production systems
- Significant performance degradation
- Loss of monitoring capabilities
- Partial service outage
- Suspicious trading patterns

**MEDIUM (P2) - Response Within 4 Hours**
- Minor security policy violations
- Suspicious but unconfirmed activity
- Non-critical vulnerability discovered
- Configuration drift detected
- Failed automated backups

**LOW (P3) - Response Within 24 Hours**
- Informational security events
- Minor policy violations
- Low-risk vulnerabilities
- Documentation issues

## Incident Response Team

### Roles and Responsibilities

**Incident Commander**
- Overall coordination
- Decision-making authority
- Communications with stakeholders
- Resource allocation

**Technical Lead**
- Technical investigation
- System analysis
- Remediation implementation
- Recovery validation

**Security Analyst**
- Threat analysis
- Log review
- Forensics data collection
- Security tool monitoring

**Communications Lead**
- Internal communications
- External notifications (if required)
- Status updates
- Documentation

## Incident Response Process

### Phase 1: Detection and Identification

**Automatic Detection:**
- Grafana security dashboard alerts
- Prometheus alert notifications
- fail2ban bans
- Nginx access log anomalies
- Application error spikes

**Manual Detection:**
- User reports
- Security audit findings
- System administrator observations
- External notifications

**Initial Actions:**
1. Document incident details:
   - Date and time of detection
   - Detection method
   - Initial symptoms
   - Systems affected
2. Assign severity level
3. Create incident ticket
4. Notify Incident Commander

### Phase 2: Containment

**Short-Term Containment (Immediate)**

For Unauthorized Access:
```bash
# Block IP at firewall
sudo ufw deny from <MALICIOUS_IP> to any

# Block in fail2ban
sudo fail2ban-client set sshd banip <MALICIOUS_IP>

# Kill active sessions
sudo pkill -u <compromised_user>

# Disable compromised account
sudo usermod -L <compromised_user>
```

For Compromised API Keys:
```bash
# Rotate secrets immediately
cd /opt/binance-traders
.\scripts\security\rotate-secrets.ps1 -RotateAll -BackupExisting

# Update Binance API keys via web interface
# Restart services with new credentials
docker compose -f docker-compose-testnet.yml restart
```

For Service Compromise:
```bash
# Isolate affected container
docker network disconnect testnet-network <container_name>

# Stop affected service
docker stop <container_name>

# Capture container logs
docker logs <container_name> > /var/log/incident_<timestamp>.log
```

For DDoS Attack:
```bash
# Enable aggressive rate limiting
# Edit nginx.conf rate limits to 1r/s temporarily

# Block attacking networks
sudo ufw deny from <ATTACKER_NETWORK>/24 to any

# Enable DDoS protection rules
sudo iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
```

**Long-Term Containment (Stabilization)**
1. Apply temporary patches
2. Implement additional monitoring
3. Document all containment actions
4. Prepare for eradication phase

### Phase 3: Eradication

**Remove Threat:**
1. Identify root cause
2. Remove malicious code/actors
3. Patch vulnerabilities
4. Update security controls
5. Verify threat removal

**Common Eradication Steps:**

For Compromised System:
```bash
# Full system update
sudo apt-get update && sudo apt-get upgrade -y

# Scan for rootkits
sudo apt-get install rkhunter chkrootkit -y
sudo rkhunter --check
sudo chkrootkit

# Review installed packages
dpkg -l | grep -i suspicious

# Check for backdoors
sudo find / -name "*.php" -mtime -7
sudo find / -perm -4000 2>/dev/null  # SUID files
```

For Container Compromise:
```bash
# Remove compromised container
docker rm -f <container_name>

# Remove potentially compromised images
docker rmi <image_name>

# Rebuild from clean source
git pull origin main
docker compose build --no-cache <service_name>
```

For Data Breach:
1. Identify scope of exposed data
2. Rotate all potentially exposed credentials
3. Notify affected parties (if applicable)
4. Implement additional access controls
5. Review and enhance data protection measures

### Phase 4: Recovery

**System Recovery:**
```bash
# Restore from clean backup (if needed)
cd /backups/binance-traders

# Restore database
docker exec -i postgres-testnet psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} < backup_YYYYMMDD.sql

# Restore configuration
cp -r config_backup_YYYYMMDD/* /opt/binance-traders/

# Restart services with monitoring
docker compose -f docker-compose-testnet.yml up -d

# Verify service health
.\scripts\security\test-security-controls.ps1
```

**Recovery Verification Checklist:**
- [ ] All services running and healthy
- [ ] No unauthorized access detected
- [ ] Monitoring and alerts operational
- [ ] Backups functioning
- [ ] Security controls in place
- [ ] No suspicious activity for 24+ hours
- [ ] Performance metrics normal
- [ ] Trading operations functioning correctly

### Phase 5: Post-Incident Activities

**Immediate (Within 24 Hours):**
1. Document complete incident timeline
2. Preserve forensic evidence
3. Calculate impact metrics:
   - Financial impact
   - Data exposure
   - Downtime duration
   - Recovery costs
4. Notify management
5. Update incident status

**Short-Term (Within 1 Week):**
1. Conduct post-incident review meeting
2. Document lessons learned
3. Identify process improvements
4. Update security controls
5. Update incident response procedures
6. Conduct additional security training

**Long-Term (Within 1 Month):**
1. Implement security enhancements
2. Update threat models
3. Review and update policies
4. Schedule penetration testing
5. Update disaster recovery plans

## Communication Templates

### Internal Notification Template

```
Subject: [SEVERITY] Security Incident - [BRIEF_DESCRIPTION]

Incident ID: INC-YYYYMMDD-####
Severity: [CRITICAL/HIGH/MEDIUM/LOW]
Detected: [DATE_TIME]
Status: [DETECTED/CONTAINED/INVESTIGATING/RESOLVED]

Summary:
[2-3 sentence description of incident]

Impact:
- Services affected: [LIST]
- Users impacted: [NUMBER/DESCRIPTION]
- Data exposure: [YES/NO/INVESTIGATING]
- Estimated recovery time: [TIME]

Actions Taken:
1. [ACTION_1]
2. [ACTION_2]

Next Steps:
1. [NEXT_STEP_1]
2. [NEXT_STEP_2]

Incident Commander: [NAME]
Technical Lead: [NAME]
Next Update: [TIME]
```

### External Notification Template (If Required)

```
Subject: Security Notice - [BRIEF_DESCRIPTION]

Date: [DATE]

Dear [STAKEHOLDER],

We are writing to inform you of a security incident that may affect your data/services.

What Happened:
[Clear, non-technical description]

What Information Was Involved:
[Specific data types]

What We Are Doing:
[Response actions taken]

What You Can Do:
[Recommended actions for recipients]

For More Information:
Contact: [EMAIL/PHONE]

We take security seriously and apologize for any inconvenience.

Sincerely,
[ORGANIZATION NAME]
```

## Forensics Data Collection

### Evidence Preservation

**System Logs:**
```bash
# Collect all relevant logs
mkdir -p /evidence/incident_$(date +%Y%m%d)
cd /evidence/incident_$(date +%Y%m%d)

# System logs
sudo cp /var/log/auth.log* ./
sudo cp /var/log/syslog* ./
sudo cp /var/log/nginx/*.log ./

# Docker logs
for container in $(docker ps -a --format '{{.Names}}'); do
    docker logs $container > ${container}_$(date +%Y%m%d_%H%M%S).log 2>&1
done

# fail2ban logs
sudo cp /var/log/fail2ban.log* ./

# UFW firewall logs
sudo cp /var/log/ufw.log* ./

# Set read-only permissions
sudo chmod -R 444 ./*
```

**Network Data:**
```bash
# Capture network connections
ss -antp > network_connections_$(date +%Y%m%d_%H%M%S).txt
netstat -antp > netstat_$(date +%Y%m%d_%H%M%S).txt

# Current firewall rules
sudo iptables -L -n -v > iptables_$(date +%Y%m%d_%H%M%S).txt
sudo ufw status verbose > ufw_status_$(date +%Y%m%d_%H%M%S).txt
```

**System State:**
```bash
# Running processes
ps auxww > processes_$(date +%Y%m%d_%H%M%S).txt

# Logged in users
w > users_$(date +%Y%m%d_%H%M%S).txt

# Cron jobs
sudo crontab -l > root_cron_$(date +%Y%m%d_%H%M%S).txt

# System information
uname -a > system_info_$(date +%Y%m%d_%H%M%S).txt
df -h > disk_usage_$(date +%Y%m%d_%H%M%S).txt
```

## Contact Information

### Emergency Contacts

**Security Team:**
- Email: security@your-organization.com
- Phone: +1-XXX-XXX-XXXX (24/7)
- Slack: #security-incidents

**Incident Commander:**
- [NAME]
- Email: [EMAIL]
- Phone: [PHONE]

**Technical Lead:**
- [NAME]
- Email: [EMAIL]
- Phone: [PHONE]

### External Resources

**VPS Provider Support:**
- Portal: [URL]
- Phone: [PHONE]
- Emergency: [EMERGENCY_PHONE]

**Binance Support:**
- Support Portal: https://www.binance.com/en/support
- API Issues: [CONTACT_METHOD]

**Law Enforcement (if required):**
- Local Police: [PHONE]
- FBI Cyber Division: https://www.fbi.gov/contact-us
- IC3: https://www.ic3.gov

## Tools and Resources

### Security Tools

**Log Analysis:**
```bash
# Search for failed login attempts
sudo grep "Failed password" /var/log/auth.log | tail -20

# Find successful logins
sudo grep "Accepted" /var/log/auth.log | tail -20

# Check for privilege escalation
sudo grep "sudo" /var/log/auth.log | tail -20

# Nginx access anomalies
sudo grep " 401 \| 403 \| 429 " /var/log/nginx/access.log | tail -20
```

**Monitoring Dashboard:**
- Grafana Security Dashboard: https://your-domain.com/grafana/d/security-monitoring
- Prometheus Alerts: https://your-domain.com/prometheus/alerts

### Incident Documentation

**Required Documentation:**
1. Incident timeline
2. Actions taken log
3. Evidence collected
4. Communication records
5. Lessons learned report
6. Cost impact analysis

**Template Location:**
- `binance-ai-traders/incidents/TEMPLATE.md`
- Create new incident: `cp TEMPLATE.md INC-$(date +%Y%m%d)-001.md`

## Testing and Drills

### Quarterly Incident Response Drill

**Objectives:**
- Test response procedures
- Validate communication channels
- Identify process gaps
- Train team members

**Drill Scenarios:**
1. Ransomware attack simulation
2. API key compromise
3. DDoS attack
4. Database breach
5. Insider threat

**Drill Procedures:**
1. Schedule drill (with or without warning)
2. Inject scenario
3. Observe response
4. Document findings
5. Review and improve

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-10-18 | Initial version | Security Team |

---

**Document Classification:** Internal Use Only  
**Review Schedule:** Quarterly  
**Last Reviewed:** 2025-10-18  
**Next Review:** 2026-01-18


