# First Time Setup After Laptop Format

Follow these steps in ORDER. Do not skip any step.

---

## Step 1 — Install Required Tools

### Terraform (Windows)
```
choco install terraform
```
Or download from: https://developer.hashicorp.com/terraform/downloads

### AWS CLI (Windows)
```
choco install awscli
```
Then configure:
```
aws configure
```
Enter: Access Key, Secret Key, region (eu-north-1), output format (json)

### Git
```
choco install git
```

### WSL (for Ansible)
```
wsl --install -d Ubuntu
```
Then inside Ubuntu WSL:
```
sudo apt update && sudo apt install ansible -y
```

### VS Code (recommended)
```
choco install vscode
```

---

## Step 2 — Generate SSH Key

In CMD (use full path, not $HOME):
```
ssh-keygen -t rsa -b 4096 -f "C:\Users\YourName\.ssh\demo-project" -N ""
```

This creates:
- `C:\Users\YourName\.ssh\demo-project`      ← private key (never share)
- `C:\Users\YourName\.ssh\demo-project.pub`  ← public key (Terraform uploads this)

---

## Step 3 — Update Your IP

1. Go to whatismyip.com
2. Open `terraform/terraform.tfvars`
3. Replace the placeholder with your IP:
   ```
   your_ip = "YOUR_ACTUAL_IP/32"
   ```

---

## Step 4 — Create S3 Remote State Bucket (run once)

```
cd terraform/remote_state
terraform init
terraform apply -auto-approve
```

---

## Step 5 — Provision Infrastructure

```
cd terraform
terraform init
terraform apply -auto-approve
```

Note the printed IPs:
```
jenkins_public_ip = "x.x.x.x"   <-- save this
app_public_ip     = "x.x.x.x"   <-- save this
```

---

## Step 6 — Update Ansible Inventory

Open `ansible/inventory/hosts.ini`
Replace the placeholder IPs with the actual IPs from Step 5.

---

## Step 7 — Copy SSH Key into WSL

Open WSL (Ubuntu) and run:
```bash
mkdir ~/.ssh && chmod 700 ~/.ssh
cp /mnt/c/Users/YourName/.ssh/demo-project ~/.ssh/demo-project
chmod 600 ~/.ssh/demo-project
```

---

## Step 8 — Run Ansible

In WSL, from the ansible folder:
```bash
cd /mnt/c/Users/YourName/Desktop/DevOps/demo-project/ansible
ansible all -i inventory/hosts.ini -m ping
ansible-playbook -i inventory/hosts.ini site.yml
```

---

## Step 9 — Set Up Jenkins (manual, ~5 minutes)

1. SSH into Jenkins server:
   ```
   ssh -i "C:\Users\YourName\.ssh\demo-project" ubuntu@JENKINS_IP
   ```
2. Get initial password:
   ```
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Open browser: http://JENKINS_IP:8080
4. Paste password, install suggested plugins, create admin user
5. Install SSH Agent plugin: Manage Jenkins → Plugins → Available → SSH Agent
6. Add credential:
   - Manage Jenkins → Credentials → Global → Add Credentials
   - Kind: SSH Username with private key
   - ID: app-server-key
   - Username: ubuntu
   - Private key: paste contents of ~/.ssh/demo-project
7. Add jenkins to docker group (on Jenkins server):
   ```
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```

---

## Step 10 — Create Jenkins Pipeline Job

1. New Item → name: demo-project → Pipeline → OK
2. Pipeline section:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: https://github.com/Digvijay-Kor/demo-project.git
   - Branch: */main
   - Script Path: Jenkinsfile
3. Build Triggers: check "GitHub hook trigger for GITScm polling"
4. Save

---

## Step 11 — Update Jenkinsfile

After terraform apply, your app server will have a NEW private IP.
Check it:
```
ssh -i "C:\Users\YourName\.ssh\demo-project" ubuntu@APP_PUBLIC_IP
ip addr show | grep 10.0
```

Update `Jenkinsfile` line:
```
APP_SERVER = 'NEW_PRIVATE_IP'
```

Commit and push:
```
git add Jenkinsfile
git commit -m "update app server IP"
git push origin main
```

---

## Step 12 — Update GitHub Actions Secret

Go to: https://github.com/Digvijay-Kor/demo-project/settings/secrets/actions
Update APP_SERVER_IP with the new app server PUBLIC IP.

---

## Step 13 — Test Everything

```
git commit --allow-empty -m "test pipeline after rebuild"
git push origin main
```

Watch Jenkins trigger automatically.
Check app at: http://APP_PUBLIC_IP:8080

---

## Destroy When Done (saves AWS costs)

```
cd terraform
terraform destroy -auto-approve

cd remote_state
terraform destroy -auto-approve
```
