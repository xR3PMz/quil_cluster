#!/bin/bash

ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
ITALIC='\033[3m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

echo ""
echo ""
echo ""
echo -e "${BLUE}"
echo "  ██╗  ██╗ █████╗ ███████╗██╗  ██╗ █████╗ ██╗    "
echo "  ██║  ██║██╔══██╗██╔════╝██║  ██║██╔══██╗██║    "
echo "  ███████║███████║███████╗███████║███████║██║    "
echo "  ██╔══██║██╔══██║╚════██║██╔══██║██╔══██║██║    "
echo -e "  ██║  ██║██║  ██║███████║██║  ██║██║  ██║██║ "
echo -e "  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝ "
echo ""
echo -e "${CYAN}                 MINING TOOLS                  ${RESET}"
echo -e "${ITALIC}${BOLD}             WWW.ADVANCED-HASH.AI              ${RESET}"
echo ""
echo -e "${BOLD}  QUIL - Cluster Tools ${RED}${ITALIC}(HiveOS BETA v0.1) 🛠️   ${RESET}"
echo ""

CONFIG_PATH="/home/user/ceremonyclient/node/.config/config.yml"

check_rigs_accessible() {
  local rigs=("${@}")
  for rig in "${rigs[@]}"; do
    echo -e ""
    echo -e "🟡  Vérification de l'accessibilité du node ${BOLD}$rig...${RESET}"

    if ! ping -c 1 "$rig" &> /dev/null; then
      echo -e ""
      echo -e "❌ ${RED}${BOLD} Erreur : Impossible d'atteindre le node $rig. Veuillez vérifier la connexion.${RESET}"
      exit 1
    fi
  done
}

generate_suggested_commands() {
  local master_threads=$1
  local master_ip=$2
  local slaves_ips=("${@:3}")
  
  echo -e "\n\n\nℹ️ ${GREEN}${BOLD} Les commandes à exécuter pour démarrer le cluster :${RESET}${RESET}"
  echo -e ""
  # Commande pour le master
  echo -e "${ORANGE}${BOLD}Master${RESET}${RESET} ($master_ip) :"
  echo "sudo screen -dmS quil bash para.sh linux amd64 0 $master_threads"

  # Commandes pour les slaves
  local previous_threads=$((master_threads - 1)) # Threads pour le premier slave
  for i in "${!slaves_ips[@]}"; do
    local slave_ip="${slaves_ips[$i]}"
    echo -e ""
    echo -e "${YELLOW}Slave${RESET} ($slave_ip) :"
    echo "sudo screen -dmS quil bash para.sh linux amd64 $previous_threads $master_threads"
    # Mise à jour pour le prochain slave
    previous_threads=$((previous_threads + master_threads))
  done
}

generate_start_commands() {
  local threads=$1
  local master_ip=$2
  local slaves_ips=("${@:3}")

  master_command="sudo screen -dmS quil bash para.sh linux amd64 0 $threads"
  
  slave_commands=()
  slave_idx=1
  slave_threads=$((threads - 1))  # Slave 1 commence avec threads - 1
  
  for ip in "${slaves_ips[@]}"; do
    # Calculer les threads pour chaque slave
    slave_command="sudo screen -dmS quil bash para.sh linux amd64 $slave_threads $threads"
    slave_commands+=("$slave_command")
    # Mise à jour du nombre de threads pour le prochain slave
    slave_threads=$((slave_threads + threads))
  done

  echo -e "\n\n\nℹ️ ${GREEN}${BOLD} Les commandes à exécuter pour démarrer le cluster :${RESET}${RESET}"
  echo -e "\n${ORANGE}${BOLD}Master${RESET}${RESET} ($master_ip) : $master_command"
  for i in "${!slaves_ips[@]}"; do
    echo -e "${YELLOW}Slave${RESET} (${slaves_ips[$i]}) : ${slave_commands[$i]}"
  done
  
  read -p "Voulez-vous exécuter ces commandes sur les nodes distants ? (y/n) : " confirm
  if [[ "$confirm" == "y" ]]; then
  echo -e "\n "
  read -sp "(Par défaut 1 sur HiveOS) Votre mot de passe connexion SSH : " password
    for i in "${!slave_commands[@]}"; do
      slave_ip="${slaves_ips[$i]}"
      slave_command="${slave_commands[$i]}"
      echo ""
      echo -e "🟡 ${YELLOW}Exécution de la commande pour le slave sur ${BOLD}$slave_ip...${RESET}"
      echo ""
      sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@"$slave_ip" "cd /home/user/ceremonyclient/node && $slave_command"
      if [ $? -eq 0 ]; then
        echo -e "🟢 ${GREEN} Commande pour le slave envoyée avec succès sur${RESET} $slave_ip."
      else
        echo -e "🔴 ${RED} Erreur lors de l'envoi de la commande pour le slave sur${RESET} $slave_ip."
      fi
    done
    echo ""
    echo -e "⏳ Attente de 15 secondes avant d'exécuter la commande pour le master..."
    sleep 15
    echo ""
    echo -e "🟡 ${YELLOW} Exécution de la commande pour le master sur ${BOLD}$master_ip...${RESET}"
    echo ""
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@"$master_ip" "cd /home/user/ceremonyclient/node && $master_command"
    if [ $? -eq 0 ]; then
      echo -e "🟢 ${GREEN} Commande pour le ${BOLD}Master${RESET} envoyée avec succès sur${RESET} $master_ip."
    else
      echo -e "🔴 ${RED} Erreur lors de l'envoi de la commande pour le Master sur${RESET} $master_ip."
    fi

    echo -e "✅ ${GREEN}${BOLD} Cluster démarré avec succès sur les nodes distantes.${RESET} 🚀"
  else
    echo -e "❌ ${RED}${BOLD} Opération annulée par l'utilisateur.${RESET}"
  fi
}

save_cluster_configuration() {
  local filename=$1
  local master_ip=$2
  local master_threads=$3
  shift 3
  local slaves_ips=("$@")

  local json_content="{\n"
  json_content+="  \"master_ip\": \"$master_ip\",\n"
  json_content+="  \"master_threads\": $master_threads,\n"
  json_content+="  \"slaves\": [\n"

  for i in "${!slaves_ips[@]}"; do
    if [ $i -lt $((${#slaves_ips[@]} - 1)) ]; then
      json_content+="    \"${slaves_ips[$i]}\",\n"
    else
      json_content+="    \"${slaves_ips[$i]}\"\n"
    fi
  done

  json_content+="  ]\n"
  json_content+="}"

  # Sauvegarder dans un fichier
  echo -e "$json_content" > "$filename"
  echo -e "\n\n\n📁 Configuration sauvegardée dans le fichier : ${YELLOW}${BOLD}$filename${RESET} \n"
}

start_cluster_from_file() {
  read -p "Entrez le chemin du fichier de configuration (ex: /path/to/cluster.json) : " config_file

  if [ ! -f "$config_file" ]; then
    echo -e "\n❌ ${RED}Fichier non trouvé : ${BOLD}$config_file${RESET}"
    exit 1
  fi

  if ! jq empty "$config_file" &>/dev/null; then
    echo -e "\n❌ ${RED}Le fichier JSON est invalide. Veuillez vérifier sa syntaxe.${RESET}"
    exit 1
  fi

  master_ip=$(jq -r '.master_ip' "$config_file")
  master_threads=$(jq -r '.master_threads' "$config_file")
  
  slaves_ips=()
  while IFS= read -r slave; do
    slaves_ips+=("$slave")
  done < <(jq -r '.slaves[]' "$config_file")

  echo -e "\n📄 Chargement de la configuration :"
  echo -e "   Master IP: $master_ip"
  echo -e "   Threads Master: $master_threads"
  echo -e "   Slaves: ${slaves_ips[*]}"

  generate_start_commands "$master_threads" "$master_ip" "${slaves_ips[@]}"
}

data_worker_cluster() {
    echo -e "\n--- ${CYAN}${BOLD}RECUPERER LES INFORMATIONS D'UN CLUSTER/NODE${RESET} ---"
    echo ""
    echo -e "${BOLD}1.${RESET}${YELLOW} Récupérer les informations via adresse IP${RESET} 📡"
    echo -e "${BOLD}2.${RESET}${YELLOW} Récupérer les informations depuis un fichier de sauvegarde${RESET} 📄"
    echo ""
    read -p "Veuillez choisir une option (1 ou 2) : " method_choice
    echo ""
    if [[ "$method_choice" == "1" ]]; then
            
        echo -e "\n--- ${CYAN}${BOLD}AFFICHER LA BALANCE QUIL${RESET} ---"
        read -p "Entrez l'adresse IP du master (ex: 192.168.1.20) : " master_ip
        read -sp "(Par défaut 1 sur HiveOS) Votre mot de passe SSH : " password
        echo ""
        echo -e "\n⏳ Connexion au master ${BOLD}$master_ip${RESET} et exécution de la commande..."

        # Définir le répertoire où se trouvent les fichiers node
        DIR_PATH="/home/user/ceremonyclient/node"
        
        # Récupérer le nom du fichier le plus récent
        latest_node=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@"$master_ip" "ls -v $DIR_PATH/node-*-linux-amd64 2>/dev/null | tail -n 1")
        
        # Vérifier si la récupération de la version a réussi
        if [[ -n "$latest_node" ]]; then
            # Extraire la version du nom du fichier
            version=$(basename "$latest_node" | awk -F'[-]' '{print $2}')
            
            # Construire la commande SSH pour exécuter le node avec la version dynamique
            SSH_COMMAND="cd $DIR_PATH && sudo ./node-$version-linux-amd64 -node-info"
            
            # Exécuter la commande SSH
            output=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@"$master_ip" "$SSH_COMMAND" 2>/dev/null)
            
            # Vérifier si la commande SSH a réussi
            if [[ $? -eq 0 ]]; then
                echo -e "\n✅ ${GREEN}Balance récupérée avec succès :${RESET}"
                
                peer_id=$(echo "$output" | grep "Peer ID" | awk -F": " '{print $2}')
                prover_ring=$(echo "$output" | grep "Prover Ring" | awk -F": " '{print $2}')
                active_workers=$(echo "$output" | grep "Active Workers" | awk -F": " '{print $2}')
                owned_balance=$(echo "$output" | grep "Owned balance" | awk -F": " '{print $2}')
                
                echo ""
                echo -e "${CYAN}Version node:${RESET} ${BOLD}$version${RESET}"
                echo -e "${CYAN}ID:${RESET} ${BOLD}$peer_id${RESET}"
                echo -e "${CYAN}Ring:${RESET} ${BOLD}$prover_ring${RESET}"
                echo -e "${CYAN}Workers:${RESET} ${BOLD}$active_workers${RESET}"
                echo -e "${CYAN}Balance:${RESET} ${BOLD}$owned_balance${RESET}"
                echo ""
            else
                echo -e "❌ ${RED}Erreur : Impossible de récupérer les informations du cluster. Veuillez vérifier la connexion SSH.${RESET}"
            fi
        else
            echo -e "❌ ${RED}Erreur : Impossible de trouver le fichier node sur le master.${RESET}"
        fi

    elif [[ "$method_choice" == "2" ]]; then

    read -p "Entrez le chemin complet du fichier de sauvegarde (.json) : " backup_file
    if [[ -f "$backup_file" ]]; then

        echo -e "\n✅ ${GREEN}Fichier de sauvegarde trouvé, récupération des informations...${RESET}"
        echo ""

        master_ip=$(jq -r '.master_ip' "$backup_file")
        master_threads=$(jq -r '.master_threads' "$backup_file")
        slave_ips=$(jq -r '.slaves[]' "$backup_file")

        # Calculer le nombre d'IP uniques parmi les slaves
        unique_slave_count=$(echo "$slave_ips" | sort | uniq | wc -l)

        # Recalculer master_threads en incluant le master lui-même
        total_threads=$((master_threads * (unique_slave_count + 1)))

        if [[ "$master_ip" != "null" && "$master_threads" -gt 0 ]]; then

            read -sp "(Par défaut 1 sur HiveOS) Votre mot de passe SSH : " password
            echo ""
            echo -e "\n⏳ Connexion au master ${BOLD}$master_ip${RESET} et exécution de la commande..."

            # Récupérer la dernière version du node sur le master
            latest_node=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@"$master_ip" "ls -v /home/user/ceremonyclient/node/node-*-linux-amd64 2>/dev/null | tail -n 1")

            # Vérifier si la récupération de la version a réussi
            if [[ -n "$latest_node" ]]; then
                # Extraire la version du nom du fichier
                version=$(basename "$latest_node" | awk -F'[-]' '{print $2}')
                
                
                # Construire la commande SSH pour exécuter le node avec la version dynamique
                SSH_COMMAND="cd /home/user/ceremonyclient/node/ && sudo ./node-$version-linux-amd64 -node-info"
                
                # Exécuter la commande SSH
                output=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@"$master_ip" "$SSH_COMMAND" 2>/dev/null)
                
                # Vérifier si la commande SSH a réussi
                if [[ $? -eq 0 ]]; then
                    echo -e "\n✅ ${GREEN}Balance récupérée avec succès :${RESET}"

                    peer_id=$(echo "$output" | grep "Peer ID" | awk -F": " '{print $2}')
                    prover_ring=$(echo "$output" | grep "Prover Ring" | awk -F": " '{print $2}')
                    active_workers=$(echo "$output" | grep "Active Workers" | awk -F": " '{print $2}')
                    owned_balance=$(echo "$output" | grep "Owned balance" | awk -F": " '{print $2}')
                    
                    echo ""
                    echo -e "${CYAN}Version node:${RESET} ${BOLD}$version${RESET}"
                    echo -e "${CYAN}ID:${RESET} ${BOLD}$peer_id${RESET}"
                    echo -e "${CYAN}Ring:${RESET} ${BOLD}$prover_ring${RESET}"
                    
                    if [[ $(($total_threads - $active_workers)) -ge 2 ]]; then
                        base_workers=$(($total_threads - 1))
                        echo -e "${CYAN}Workers:${RESET} ❌ ${RED}${BOLD}$active_workers${RESET} workers en ligne au lieu de ${GREEN}${BOLD}$base_workers${RESET}. (Slaves Hors-ligne)"
                    else
                        echo -e "${CYAN}Workers:${RESET} ${BOLD}$active_workers${RESET}"
                    fi
                    
                    echo -e "${CYAN}Wallet:${RESET} ${BOLD}$owned_balance${RESET}"
                    echo ""
                else
                    echo -e "❌ ${RED}Erreur : Impossible de récupérer les informations du cluster. Veuillez vérifier la connexion SSH.${RESET}"
                fi
            else
                echo -e "❌ ${RED}Erreur : Impossible de trouver le fichier node sur le master.${RESET}"
            fi
        else
            echo -e "❌ ${RED}Erreur : IP du master ou master_threads introuvables ou invalides dans le fichier JSON.${RESET}"
        fi
    else
        echo -e "❌ ${RED}Erreur : Fichier de sauvegarde introuvable. Veuillez vérifier le chemin.${RESET}"
    fi
  else
      echo -e "❌ ${RED}Option non valide. Retour au menu principal.${RESET}"
  fi
}


generate_data_worker_multiaddrs() {
  local ip=$1
  local threads=$2
  local start_port=40001
  local ports=()

  if [[ $is_master == "true" ]]; then
    threads=$((threads - 1))
  fi

  for ((i=0; i<threads; i++)); do
    ports+=("'/ip4/$ip/tcp/$((start_port + i))'")
  done

  echo "${ports[@]}"
}

update_remote_config() {
  local ip=$1

  temp_config="/tmp/remote_config_$ip.yml"
  echo -e "$cluster_config" > "$temp_config"

  echo -e "\n⏳ Mise à jour de la configuration sur ${BOLD}$ip...${RESET}"
  sshpass -p "$password" scp -o StrictHostKeyChecking=no "$temp_config" user@$ip:/tmp/cluster_config.yml

  SSH_COMMAND="
    sudo sed -i '/engine:/r /tmp/cluster_config.yml' $CONFIG_PATH &&
    sudo rm /tmp/cluster_config.yml
  "

    # Commande distante correctement échappée
  SSH_COMMAND="
    if sudo grep -q 'dataWorkerMultiaddrs:' $CONFIG_PATH; then
      echo -e '\n🔄 Suppression ancienne configuration dataWorkerMultiaddrs...';
      sudo sed -i '/dataWorkerMultiaddrs:/,/]/d' $CONFIG_PATH;
    fi;
    echo -e '\n✅ Ajout de la nouvelle configuration dataWorkerMultiaddrs...';
    sudo sed -i '/engine:/r /tmp/cluster_config.yml' $CONFIG_PATH;
    sudo rm /tmp/cluster_config.yml;
  "

  sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@$ip "$SSH_COMMAND"

  if [ $? -eq 0 ]; then
    echo -e ""
    echo -e "✅ Configuration mise à jour avec succès sur${BOLD} $ip.${RESET}"
  else
    echo -e ""
    echo -e "❌ Erreur : Échec de la mise à jour sur${BOLD} $ip.${RESET}"
  fi

  sudo rm -f "$temp_config"
}

remove_config_from_file() {
  # Demander le chemin du fichier de configuration
  read -p "Entrez le chemin du fichier de configuration (ex: /path/to/cluster.json) : " config_file

  # Vérification du fichier
  if [ ! -f "$config_file" ]; then
    echo -e "\n❌ ${RED}Fichier non trouvé : ${BOLD}$config_file${RESET}"
    exit 1
  fi

  # Validation de la syntaxe JSON
  if ! jq empty "$config_file" &>/dev/null; then
    echo -e "\n❌ ${RED}Le fichier JSON est invalide. Veuillez vérifier sa syntaxe.${RESET}"
    exit 1
  fi

  # Extraction des IP et configuration depuis le fichier JSON
  master_ip=$(jq -r '.master_ip' "$config_file")
  slaves_ips=()
  while IFS= read -r slave; do
    slaves_ips+=("$slave")
  done < <(jq -r '.slaves[]' "$config_file")

  echo -e "\n📄 Chargement de la configuration pour suppression :"
  echo -e "   Master IP: $master_ip"
  echo -e "   Slaves: ${slaves_ips[*]}"

  echo ""
  read -sp "(Par défaut 1 sur HiveOS) Votre mot de passe SSH : " password
  echo ""

  remove_remote_config() {
    local ip=$1
    echo -e "\n⏳ Suppression de la configuration sur ${BOLD}$ip...${RESET}"
    echo ""
    SSH_COMMAND="
      if sudo grep -q 'dataWorkerMultiaddrs:' $CONFIG_PATH; then
        echo -e '🔄 Suppression de la configuration dataWorkerMultiaddrs...';
        sudo sed -i '/dataWorkerMultiaddrs:/,/]/d' $CONFIG_PATH;
      else
        echo -e 'ℹ️ Aucune configuration dataWorkerMultiaddrs trouvée sur $ip.';
      fi;
    "

    # Exécution de la commande distante
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@$ip "$SSH_COMMAND"

    if [ $? -eq 0 ]; then
      echo -e "✅ Configuration supprimée avec succès sur ${BOLD}$ip.${RESET}"
    else
      echo -e "❌ Erreur : Échec de la suppression de la configuration sur ${BOLD}$ip.${RESET}"
    fi
  }

  # Suppression de la configuration sur le Master
  remove_remote_config "$master_ip"

  # Suppression de la configuration sur chaque Slave
  for slave_ip in "${slaves_ips[@]}"; do
    remove_remote_config "$slave_ip"
  done

  echo ""
  read -p "Souhaitez-vous tuer le cluster en cours et relancer le node en mode solo sur chaque machine distante ? (y/n) : " answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then

    echo -e "\n🛑 Fermeture du cluster 🕹️"
    echo ""
    # Fonction pour tuer le processus de cluster et relancer en solo
    close_node_cluster() {
      local ip=$1

      SSH_COMMAND="sudo pkill -f quil"

      # Exécution de la commande distante
      sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@$ip "$SSH_COMMAND"

      if [ $? -eq 0 ]; then
        echo -e "✅ Fermeture du node cluster sur ${BOLD}$ip.${RESET}"
      else
        echo -e "❌ Erreur : Impossible de fermer le node cluster sur ${BOLD}$ip.${RESET}"
      fi
    }

    # Redémarrer le master en solo
    close_node_cluster "$master_ip"

    # Redémarrer chaque slave en solo
    for slave_ip in "${slaves_ips[@]}"; do
      close_node_cluster "$slave_ip"
    done

    echo -e "\n⚡️ Execution nodes en solo 🖥️"

    start_node_solo() {
      local ip=$1
      echo -e "\n⏳ Redémarrage du node en solo sur ${BOLD}$ip...${RESET}"

      SSH_COMMAND="cd /home/user/ceremonyclient/node/ && sudo screen -dmS quil ./release_autorun.sh"

      # Exécution de la commande distante
      sshpass -p "$password" ssh -o StrictHostKeyChecking=no user@$ip "$SSH_COMMAND"

      if [ $? -eq 0 ]; then
        echo -e "✅ Node ${BOLD}$ip${RESET} démarré en solo."
      else
        echo -e "❌ Erreur : Impossible de lancer le node ${BOLD}$ip${RESET} en solo."
      fi
    }

    # Redémarrer le master en solo
    start_node_solo "$master_ip"

    # Redémarrer chaque slave en solo
    for slave_ip in "${slaves_ips[@]}"; do
      start_node_solo "$slave_ip"
    done

  fi
}



# Menu principal
echo -e ""
echo -e "---------- ${CYAN}${BOLD}MENU PRINCIPAL${RESET}${RESET} ----------"
echo -e ""
echo -e "${BOLD}1.${RESET} ${YELLOW}Démarrer un cluster manuellement${RESET} ⚡"
echo -e "${BOLD}2.${RESET} ${YELLOW}Démarrer un cluster depuis un fichier de sauvegarde${RESET} 📄"
echo -e "${BOLD}3.${RESET} ${YELLOW}Configurer un nouveau cluster${RESET} 🔧"
echo -e "${BOLD}4.${RESET} ${YELLOW}Démonter un cluster à partir d'un fichier de sauvegarde${RESET} 💥"
echo -e "${BOLD}5.${RESET} ${YELLOW}Récupérer les informations d'un cluster/node (Balance/Workers etc..)${RESET} 💰"
echo ""
read -p "Veuillez choisir une option (1, 2, 3 ou 4) : " choice

if [[ "$choice" == "1" ]]; then

  echo -e "\n--- ${CYAN}${BOLD}DEMARRER UN CLUSTER${RESET} ---"
  echo -e ""

  read -p "Entrez l'adresse IP locale du master (ex: 192.168.1.20) : " master_ip
  read -p "Entrez le nombre de threads utilisés par le master (ex: 32) : " master_threads

  slaves_ips=()
  while true; do
    read -p "Ajouter un slave ? (y/n) : " add_slave
    if [[ "$add_slave" == "n" ]]; then
      break
    fi
    read -p "Entrez l'adresse IP locale du slave (ex: 192.168.1.23) : " slave_ip
    # read -p "Entrez le nombre de threads utilisés par le slave (ex: 32) : " slave_threads
    slaves_ips+=("$slave_ip")
  done

  generate_start_commands "$master_threads" "$master_ip" "${slaves_ips[@]}"

elif [[ "$choice" == "2" ]]; then
    echo -e "\n--- ${CYAN}${BOLD}DEMARRER UN CLUSTER${RESET} ---"
    start_cluster_from_file

elif [[ "$choice" == "3" ]]; then
  echo -e "\n--- ${CYAN}${BOLD}CONFIGURER UN NOUVEAU CLUSTER${RESET} ---"
  echo -e ""

  read -p "Entrez l'adresse IP locale du master (ex: 192.168.1.20) : " master_ip
  read -p "Entrez le nombre de threads utilisés par le master (ex: 32) : " master_threads

  is_master="true"
  master_multiaddrs=$(generate_data_worker_multiaddrs "$master_ip" "$master_threads")

  cluster_config="  dataWorkerMultiaddrs: ["

  cluster_config+="\n  $(echo "$master_multiaddrs" | sed 's/ /,\n  /g'),"

  slaves_ips=()
  while true; do
    read -p "Ajouter un slave ? (y/n) : " add_slave
    echo -e ""
    if [[ "$add_slave" == "n" ]]; then
      break
    fi

    read -p "Entrez l'adresse IP locale du slave (ex: 192.168.1.23) : " slave_ip
    # read -p "Entrez le nombre de threads utilisés par le slave (ex: 32) : " slave_threads

    is_master="false"
    slave_multiaddrs=$(generate_data_worker_multiaddrs "$slave_ip" "$master_threads")
    cluster_config+="\n  $(echo "$slave_multiaddrs" | sed 's/ /,\n  /g'),"
    slaves_ips+=("$slave_ip")
  done

    echo ""
    read -sp "(Par défaut 1 sur HiveOS) Votre mot de passe connexion SSH : " password
    echo ""
    read -p "Entrez un nom de configuration : " name_file
    echo ""

  cluster_config+="\n  ]  # Generate from Quil - Cluster Tools"

  echo -e "\nℹ️ ${ORANGE}${BOLD} Configuration générée pour le cluster :${RESET}${RESET}"
  echo ""
  echo -e "$cluster_config"
  echo ""
  rigs=("$master_ip" "${slaves_ips[@]}")
  check_rigs_accessible "${rigs[@]}"

  update_remote_config "$master_ip"

  for slave_ip in "${slaves_ips[@]}"; do
    update_remote_config "$slave_ip"
  done

  generate_suggested_commands "$master_threads" "$master_ip" "${slaves_ips[@]}"

  config_file="${master_ip##*.}-${master_threads}-${name_file}.json"
  save_cluster_configuration "$config_file" "$master_ip" "$master_threads" "${slaves_ips[@]}"

  elif [[ "$choice" == "4" ]]; then
    remove_config_from_file

  elif [[ "$choice" == "5" ]]; then
    data_worker_cluster

else
  echo -e "❌ ${RED} Choix invalide. Fermeture du script.${RESET}"
fi