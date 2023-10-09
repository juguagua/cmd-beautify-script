#!/bin/bash

# This script is used to beautify the command line by some commonly used tools for centos systems

# Check prerequisites : python, git, rust
echo "Check prerequisites : python, git, rust ..."
command -v python > /dev/null || command -v python3 > /dev/null || { echo "Python or Python3 is required but not installed. Exiting..."; exit 1; }
command -v git > /dev/null || { echo "Git is required but not installed. Exiting..."; exit 1; }
command -v rustc > /dev/null || { echo 'Rust is required but not installed. Execute "curl https://sh.rustup.rs -sSf | sh" to install'; exit 1; }

echo "Starting the server beautification process..."

# Install epel-release
echo "Installing epel-release..."
yum install -y epel-release || { echo "Failed to install epel-release"; exit 1; }

# Install zsh
echo "Installing ZSH..."
yum install -y zsh || { echo "Failed to install zsh"; exit 1; }

# Verify zsh installation
echo "Verifying ZSH installation..."
if grep -q "/bin/zsh" /etc/shells; then
    echo "ZSH is already installed."
else
    echo "Error: ZSH installation failed."
    exit 1
fi

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
[ -f install.sh ] && rm -f install.sh
[ -d /root/.oh-my-zsh ] && rm -rf /root/.oh-my-zsh
wget https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh || { echo "Failed to clone oh my zsh"; exit 1; }
chmod +x install.sh
sed -i 's|REPO=${REPO:-ohmyzsh/ohmyzsh}|REPO=${REPO:-mirrors/ohmyzsh}|' install.sh
sed -i 's|REMOTE=${REMOTE:-https://github.com/${REPO}.git}|REMOTE=${REMOTE:-https://gitee.com/${REPO}.git}|' install.sh
RUNZSH=no ./install.sh || { echo "Failed to install oh my zsh"; exit 1; }

# Configure zsh as default shell
if ! command -v chsh > /dev/null; then 
    echo "chsh command not found. Installing util-linux-user..."
    yum install -y util-linux-user || { echo "Failed to install util-linux-user"; exit 1; }
fi
echo "Setting ZSH as the default shell for root..."
chsh -s /bin/zsh || { echo "Failed to setting zsh as default shell"; exit 1; }

# Modify .zshrc for environment variable
echo "Updating .zshrc for environment variables..."
cp ~/.zshrc ~/.zshrc.bak  # Backup .zshrc
echo "source /etc/profile" >> ~/.zshrc  
echo "source ~/.bashrc" >> ~/.zshrc
echo "source ~/.bash_profile" >> ~/.zshrc

# Configure zsh theme
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="random"/' ~/.zshrc

# Install autojump
echo "Installing autojump..."
if ! command -v j > /dev/null; then
    git clone https://github.com/joelthelion/autojump.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump || { echo "Failed to install autojump"; exit 1; }
    cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump

    # Check if python or python3 exists and then run install.py with the correct interpreter
    if command -v python > /dev/null; then
        output=$(python ./install.py)
    elif command -v python3 > /dev/null; then
        output=$(python3 ./install.py)
    else
        echo "Neither python nor python3 found. Exiting..."
        exit 1;
    fi

    # Add the autojump configuration line to .zshrc
    echo "$output" | grep '\[ -s /root/.autojump/etc/profile.d/autojump.sh \]' >> ~/.zshrc

    cd ..
fi

# Install zsh-syntax-highlighting
echo "Installing zsh-syntax-highlighting..." 
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || { echo "Failed to install zsh-syntax-highlighting"; exit 1; }


# Install zsh-autosuggestions
echo "Installing zsh-autosuggestions..."
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || { echo "Failed to install zsh-autosuggestion"; exit 1; }
fi

# update plugins in ~/.zshrc
echo "Configuring plugins in .zshrc..."
sed -i '/^plugins=(/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)' ~/.zshrc

# Installing exa
echo "Installing exa..."
cargo install exa || { echo "Failed to install exa"; exit 1; }


# Installing bat
echo "Installing bat..."
cargo install bat || { echo "Failed to install bat"; exit 1; }

# Installing tldr
echo "Installing tldr..."
yum install -y nodejs npm || { echo "Failed to install npm"; exit 1; }
yum install -y tldr || { echo "Failed to install tldr"; exit 1; }

# 安装Htop
echo "Installing htop..."
yum install -y htop || { echo "Failed to install htop"; exit 1; }
