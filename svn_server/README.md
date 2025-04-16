# 🚀 Setting Up an SVN Server with Docker, SSH, and TortoiseSVN – A Modern DevOps Guide

Subversion (SVN) may be considered “old school” compared to Git, but it's still widely used in enterprises where long-lived assets and centralized control are priorities. If you're managing legacy projects or need to deploy a quick, secure version control system, this tutorial is for you.

In this post, I’ll walk you through **setting up a secure, Dockerized SVN server with SSH access** and show how to connect to it using **TortoiseSVN on Windows**. We'll also cover automation for repository backup and initialization.

---

## 🛠️ Project Structure at a Glance

This project is cleanly organized for clarity and portability:


```
📁 svn_server/
│
├── 📁 data/                                # Persistent data storage
│   ├── 📁 backup/                          # Daily SVN dump backups (timestamped)
│   ├── 📁 dump_files/                      # Preloaded .dump files for repo initialization
│   └── 📁 repositories/                    # Active SVN repositories
│
├── 📁 keys/                                # SSH keys for secure access
│   ├── 🔑 user1_key.pub                   # user1 public key
│   ├── 🔐 user1_key                       # user1 private key (OpenSSH format)
│   ├── 🔐 user1_key.ppk                   # user1 private key (PuTTY format)
│   ├── 🔑 user2_key.pub                   # user2 public key
│   ├── 🔐 user2_key                       # user2 private key (OpenSSH format)
│   └── 🔐 user2_key.ppk                   # user2 private key (PuTTY format)
│
├── 📄 Dockerfile_svn                      # Dockerfile to build SVN + SSH server image
├── 📄 entrypoint.sh                       # Container startup script (initializes repos, services)
└── 📄 backup_svn_repo.sh                  # Cron-based script to automate daily repository backups
```

---

## 🐳 Step 1: Build and Launch the SVN Server with Docker

This `Dockerfile` provisions a containerized **Subversion (SVN)** server on **Ubuntu 20.04**, with secure **SSH access**, automated repository management, and daily backup capabilities. It is designed to simplify SVN server deployment while following best practices for security, automation, and maintainability.

- **Base Image**: Uses a minimal Ubuntu 20.04 image to ensure compatibility and stability.
- **SVN & SSH Installation**: Installs `subversion`, `openssh-server`, and `cron` to support version control, secure remote access, and scheduled backups.
- **User Management**:
  - Creates two application users (`user1`, `user2`) with predefined user IDs and passwords.
  - Adds both users to a shared group (`vboxsf`) for consistent volume access (especially useful in VirtualBox environments).
- **SSH Key Authentication**:
  - Public keys for each user are added to their respective `.ssh/authorized_keys` directories.
  - Password-based SSH login is disabled to enhance security.
- **Custom Port Exposure**: SSH listens on port `2024` (configurable) to avoid conflicts with host SSH.
- **Repository Storage**:
  - Repositories are stored in `/svn/repositories`, with optional data imports from `/svn/dump_files`.
  - Data is persisted using mounted Docker volumes.
- **Entrypoint Initialization**:
  - The `entrypoint.sh` script initializes the SVN repositories (if not present), loads dump files, sets ownership and permissions, and starts SSH and cron services.
  - Ensures the server is operational, persistent, and self-healing on restarts.
- **Automated Backups**:
  - `backup_svn_repo.sh` runs daily (cron at 1 AM) to back up all repositories into timestamped `.svn_dump` files stored in `/svn/backup`.
  - Optional compression and cleanup logic is included (commented for customization).
  - This ensures disaster recovery and easy migration.
  - **Best Practice:** Mount `backup/` to a persistent volume or remote storage.

---

### 🛠️ Build & Run Instructions

```bash
# Build the Docker image
docker build -f Dockerfile_svn -t svn_server:v1 .

# Run the container
docker run -d \
  -p 2024:2024 \
  -v $(pwd)/data:/svn \
  --name svn_container \
  svn_server:v1
```

- `$(pwd)/data`: Persists SVN repositories, backup files, and dump imports.
- `2024`: Port mapped to host to avoid SSH conflicts.


---

## 🔐 Step 2: Secure Access with SSH Keys

Here’s an improved and more detailed version of your section with clear instructions, formatting, and added context:

---

### ✅ Generate SSH Keys (Linux, macOS, or WSL)

To enable secure, password-less SSH access to the SVN container, generate a new RSA key pair:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

- When prompted, you can press `Enter` to accept the default file location (`~/.ssh/id_rsa`).
- This will generate:
  - 🔐 `id_rsa` (your private key)
  - 🔑 `id_rsa.pub` (your public key)

---

### 📁 Add Public Key to the Project

Copy the generated **public key (`id_rsa.pub`)** into the project’s `keys/` directory and rename it according to the target user:

```
svn_server/
└── keys/
    └── user1_key.pub
```

Repeat this step for each user who needs SSH access.

> ✅ Make sure to **not** share the private key. Only the public key goes into the container.

---

### 🔐 Connect to the Container via SSH

Once the container is running, connect securely using your private key:

```bash
ssh -i ~/.ssh/id_rsa -p 2024 user1@localhost
```

- `-i`: Specifies the private key.
- `-p 2024`: Uses the custom SSH port configured in the container.
- `user1@localhost`: Logs in as `user1` inside the container.

---

Here's the updated version of your **Step 4: Setup SSH Connection in PuTTY**, now with instructions on connecting from another computer on the same LAN and from the internet, including router port forwarding:

---

## 🪪 Step 4: Setup SSH Connection in PuTTY (Windows)

To connect to your SVN Docker container using SSH and the private key for `user1`, follow these steps:

---

### ✅ Prerequisites:
- You’ve already generated a key pair and have the **PuTTY-compatible private key file** (`user1_key.ppk`) stored in `keys/`.
- The container is running and exposing **SSH on port 2024**.
- `user1`'s public key was added inside the container.
- Your host machine (running Docker) is connected to a LAN or the internet with port 2024 open if remote access is needed.

---

### 🛠️ Instructions (Local Computer)

1. **Open PuTTY**

   Launch the PuTTY application.

2. **Configure Basic Connection Info**
   - In the **"Session"** category:
     - **Host Name (or IP address):** `localhost`
     - **Port:** `2024`
     - **Connection type:** Select `SSH`
     - **Saved Sessions:** Enter `svn_server` (this will be the name you save the configuration under)

3. **Set the SSH Username**
   - Go to **Connection → Data**
   - In the **"Auto-login username"** field, enter:  
     ```
     user1
     ```

4. **Attach the Private Key**
   - Go to **Connection → SSH → Auth**
   - Under **"Private key file for authentication"**, click **Browse** and select:
     ```
     keys/user1_key.ppk
     ```

5. **Save the Session for Reuse**
   - Go back to the **Session** category
   - Click **Save** to store the configuration under the name `svn_server`

6. **Connect to the Container**
   - With the `svn_server` session selected, click **Open**
   - A terminal window will appear and you should be logged in as `user1` without needing a password.

---

### 🌐 Access from Another Computer on the Same Network (LAN)

If you’re accessing the SVN container from another machine on the **same local network**, replace `localhost` with the **local IP address** of the host machine (running the Docker container):

```
Example: 192.168.1.100
```

In PuTTY:
- **Host Name:** `192.168.1.100`
- **Port:** `2024`

Make sure port 2024 is **open in the host's firewall** (e.g., Windows Defender Firewall or `ufw` on Linux).

---

### 🌍 Access from Outside via the Internet (Remote SSH)

To connect from a computer **outside your network (over the internet)**:

1. **Find your public IP address**  
   You can use a service like [whatismyip.com](https://www.whatismyip.com/) on the host machine.

2. **Configure your Router to Forward Port 2024**  
   - Log into your router’s admin panel.
   - Add a **port forwarding rule**:
     - **External Port:** `2024`
     - **Internal IP:** Local IP of the host machine (e.g., `192.168.1.100`)
     - **Internal Port:** `2024`
     - **Protocol:** TCP

3. **Update PuTTY Settings**  
   - In the **Host Name** field, enter your **public IP address**
   - Ensure the port is set to `2024`

⚠️ **Security Tip:** If exposing SSH to the internet, make sure:
- Only key-based authentication is allowed (no passwords).
- Use a strong private key and consider changing the port from 2024 to something more obscure.
- Monitor logs and optionally use fail2ban or similar tools to mitigate brute-force attempts.

---

📝 **Tip:** If it’s your first time connecting, PuTTY may prompt you to accept the host's SSH fingerprint—click **Yes** to continue.

---

Let me know if you want a screenshot-based version or a Markdown export for documentation.


---

## 🧰 Step 5: SVN Client Setup with TortoiseSVN

For Windows users, **TortoiseSVN** offers a user-friendly interface to interact with the server.

### 📦 Install:
👉 [Download TortoiseSVN](https://tortoisesvn.net/downloads.html)

### 🔁 Checkout the Repository:
1. Create a local folder like `C:\svn\repo1`
2. Right-click → **SVN Checkout**
3. Use the URL:  
   ```
   svn+ssh://svn_server/svn/repositories/repo1
   ```

4. When prompted, accept the SSH key and enter your credentials.

### 🚀 Common Operations:
- **Checkout** – Pull the repo for the first time.
- **Commit** – Send your changes back.
- **Update** – Sync with the latest repo state.

---

## 🧠 Why Use Docker for SVN?

- **Clean environment**: No risk of corrupting your local system.
- **Easy portability**: Move the whole server as a Docker image.
- **Automated provisioning**: Scripts like `entrypoint.sh` handle repo loading on startup.
- **Security**: SSH authentication adds a robust layer over HTTP(S).

---

## 🏁 Final Thoughts

This setup is ideal for:
- Legacy development workflows
- Enterprise teams needing centralized version control
- Educators and trainers teaching core VCS concepts

With Docker + SSH + TortoiseSVN, you get a **modern, secure, and maintainable** SVN solution—perfect for hybrid teams and long-term infrastructure.
