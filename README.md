  <img width="518" alt="image" src="https://github.com/user-attachments/assets/6c1c935f-8843-4eb6-810d-0ed17c3576f7">



- Téléchargement: https://github.com/xR3PMz/quil_cluster/releases/tag/cluster_config

- Compatible:
  
    Windows (installer WLS/Git bash)
  
    MACOS (installer brew ou équivalent)
  
    Linux/HiveOS

- Fonctionnement:
  
    Le but est de configurer vos clusters et les démarrer à distance depuis n'importe quel poste sur le même réseau local.
    Pour le moment cet outil ne peux configurer et executer que des nodes fonctionnant depuis HiveOS et Linux (installé dans le répertoire /home/user/ceremonyclient/node)

- Tutoriel:
  
1. Vous devez installer sshpass et le para.sh dans le répertoire de chaque node.
   
    `sudo apt update && sudo apt install sshpass`
   
    `cd /home/user/ceremonyclient/node/ && wget https://advanced-hash.ai/downloads/para.sh && chmod +x para.sh`

3. 

  A. Sur le node qui execute le script et qui vous servira à configurer installez sshpass/jq ainsi que l'outil
  
  Pour vos nodes sous HiveOS:
    
      sudo apt update && sudo apt install sshpass jq
      cd /home/user/ceremonyclient/node/
      wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_hiveOS.sh
      chmod +x config_cluster_hiveOS.sh
      wget https://advanced-hash.ai/downloads/para.sh
      chmod +x para.sh
      ./config_cluster_hiveOS.sh
  
  Pour vos nodes sous Linux:
    
      sudo apt update && sudo apt install sshpass jq
      cd /home/user/ceremonyclient/node/
      wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_linux.sh
      chmod +x config_cluster_linux.sh
      wget https://advanced-hash.ai/downloads/para.sh
      chmod +x para.sh
      ./config_cluster_linux.sh
      
  B. Si vous souhaitez executer l'outil depuis un autre poste (qui n'est pas un node):
  
  Pour vos nodes sous HiveOS:
    
      sudo apt update && sudo apt install sshpass jq
      
      wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_hiveOS.sh && chmod +x config_cluster_hiveOS.sh
      
  Pour vos nodes sous Linux:
    
      sudo apt update && sudo apt install sshpass jq
      
      wget https://github.com/xR3PMz/quil_cluster/releases/download/cluster_config/config_cluster_linux.sh && chmod +x config_cluster_linux.sh

3. Pour executer l'outil: 

    `./config_cluster_hiveOS.sh`

Attention, si vous avez déjà éditer vos config.yml veillez à ce qu'il n'y est pas de configuration existante.
Vos nodes doivent être démarré, minage Quil arrêté! (logique vous m'direz!)
Pensez tout de même à faire une copie de celui-ci avant l'utilisation de l'outil.



