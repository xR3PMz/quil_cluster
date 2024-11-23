Téléchargement : https://github.com/xR3PMz/quil_cluster/releases/tag/cluster_config

Compatible:

Windows (installateur WLS/Git bash)

MACOS (installateur Brew ou équivalent)

Linux/HiveOS

Fonctionnement :

Le but est de configurer vos clusters et les démarrer à distance depuis n'importe quelle poste sur le même réseau local. Pour le moment cet outil ne peut configurer et exécuter que des nœuds fonctionnant depuis HiveOS ou Linux (installé dans le répertoire /home/user/ceremonyclient/node)

Tutoriel:

Vous devez installer sshpass et le para.sh dans le répertoire de chaque nœud.

    sudo apt update && sudo apt install sshpass

    HiveOS : 
        cd /home/user/ceremonyclient/node/ && wget https://advanced-hash.ai/downloads/para.sh && chmod +x para.sh

    Linux: 
        cd $HOME/ceremonyclient/node/ && wget https://advanced-hash.ai/downloads/para.sh && chmod +x para.sh

A. Sur le nœud qui exécute le script et qui vous servira à configurer installez sshpass/jq ainsi que l'outil

    Pour vos nœuds sous HiveOS :
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install sshpass jq
        cd /home/user/ceremonyclient/node/
        wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_hiveOS.sh
        chmod +x config_cluster_hiveOS.sh
        wget https://advanced-hash.ai/downloads/para.sh
        chmod +x para.sh
        ./config_cluster_hiveOS.sh

    Pour vos nœuds sous Linux :
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install sshpass jq
        cd $HOME/ceremonyclient/node/
        wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_linux.sh
        chmod +x config_cluster_linux.sh
        wget https://advanced-hash.ai/downloads/para.sh
        chmod +x para.sh
        ./config_cluster_linux.sh

B. Si vous souhaitez exécuter l'outil depuis un autre poste (qui n'est pas un nœud) :

    Pour vos nœuds sous HiveOS :
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install sshpass jq
        cd /home/user/ceremonyclient/node/
        wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_hiveOS.sh && chmod +x config_cluster_hiveOS.sh
        ./config_cluster_hiveOS.sh

    Pour vos nœuds sous Linux :
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update && sudo apt install sshpass jq
        cd $HOME/ceremonyclient/node/
        wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_linux.sh && chmod +x config_cluster_linux.sh
        ./config_cluster_linux.sh

Pour exécuter l'outil :
    ./config_cluster_hiveOS.sh

Attention, si vous avez déjà éditer votre config.yml veillez à ce qu'il n'y est pas de configuration existante. Pensez à bien utiliser la version utilisée par vos nœuds. (Faire une configuration mixte sur des nœuds Ubuntu/HiveOS n'est pour le moment pas possible) Vos nœuds doivent être démarrés, minage Quil arrêté! (logique vous m'direz!) Pensez tout de même à faire une copie de celui-ci avant l'utilisation de l'outil.