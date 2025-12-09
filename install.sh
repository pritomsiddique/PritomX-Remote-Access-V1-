#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
#   PritomX Remote Access V1 – Auto Installer
# ==========================================

echo "Updating system..."
pkg update -y && pkg upgrade -y

echo "Installing required packages..."
pkg install -y wget curl openssh proot-distro

echo "Installing Ubuntu..."
proot-distro install ubuntu

echo "Configuring Ubuntu Desktop + VNC..."
proot-distro login ubuntu -- bash -c "
apt update -y
apt upgrade -y
apt install -y xfce4 xfce4-goodies tightvncserver sudo curl wget
mkdir -p ~/.vnc
echo 'pritomx' | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd
echo '#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup
"

echo "Creating ubuntu-start command..."
cat > $PREFIX/bin/ubuntu-start << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu -- vncserver -geometry 1280x720
EOF
chmod +x $PREFIX/bin/ubuntu-start

echo "Installing Cloudflared..."
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared
chmod +x cloudflared
mv cloudflared $PREFIX/bin/

echo "Setting SSH passwordless login..."
mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

echo "Generating SSH key..."
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

echo "Starting SSH server..."
sshd

echo "Creating Cloudflared autostart script..."
cat > $PREFIX/bin/pritomx-remote << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
sshd
cloudflared tunnel --url ssh://localhost:8022 --no-autoupdate
EOF
chmod +x $PREFIX/bin/pritomx-remote

echo "=================================================="
echo " Installation Complete! "
echo " Command to start Remote Access:"
echo "     pritomx-remote"
echo "=================================================="
