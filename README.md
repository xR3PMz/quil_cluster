<img width="549" alt="image" src="https://github.com/user-attachments/assets/f337b80c-7d46-4a32-966f-86aa1b97de37">


ATTENTION: 

Vos nodes doivent être démarré, minage Quil arrêté! (logique vous m'direz!)

Pensez tout de même à faire une copie de votre config.yml avant l'utilisation de l'outil.

Téléchargement: https://github.com/xR3PMz/quil_cluster/releases/tag/cluster_config


HIVEOS:

Tout vos nodes doivent être installé dans le répertoire: /home/user/ceremonyclient/node
Veillez à ce que vos nodes soient accessible via SSH en activant l'option dans les paramètres du rig depuis HiveOS.
Le mot de passe de vos nodes doivent être identique. Par défaut le mot de passe est 1. (Pour des raisons d'optimisations et le déploiement rapide.)
  
1. Installer les dépendances necessaires sur chaque node:
   
        sudo apt update && sudo apt install gpg
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install sshpass
        cd /home/user/ceremonyclient/node/ && rm para.sh && wget https://advanced-hash.ai/downloads/para.sh && chmod +x para.sh


2. Sur le node qui execute le tool et qui vous servira à configurer votre cluster, installez gpg/sshpass/jq ainsi que l'outil:
    
        sudo apt update && sudo apt install gpg
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install jq
        cd /home/user/ceremonyclient/node/
        rm para.sh
        wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_hiveOS.sh
        chmod +x config_cluster_hiveOS.sh
        wget https://advanced-hash.ai/downloads/para.sh
        chmod +x para.sh
        ./config_cluster_hiveOS.sh

4. Pour executer l'outil: 

        ./config_cluster_hiveOS.sh

LINUX:

Tout vos nodes doivent être installé dans le répertoire: /home/user_name/ceremonyclient/node
Vous devez être identifier en user, si root l'outil ne pourra pas déployer.
Le mot de passe de vos nodes doivent être identique. (Pour des raisons d'optimisations et le déploiement rapide.)

1. Installer les dépendances necessaires sur chaque node:

        sudo apt update && sudo apt install gpg
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install sshpass
        cd $HOME/ceremonyclient/node/ && rm para.sh && wget https://advanced-hash.ai/downloads/para.sh && chmod +x para.sh

2. Sur le node qui execute le tool et qui vous servira à configurer votre cluster, installez gpg/sshpass/jq ainsi que l'outil:
    
        sudo apt update && sudo apt install gpg
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install sshpass jq
        cd $HOME/ceremonyclient/node/
        rm para.sh
        wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_linux.sh
        chmod +x config_cluster_linux.sh
        wget https://advanced-hash.ai/downloads/para.sh
        chmod +x para.sh
        ./config_cluster_linux.sh

3. Pour executer l'outil: 

        ./config_cluster_linux.sh






