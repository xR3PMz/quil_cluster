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
echo -e " ${BOLD}      QUIL - Cluster Tools ${RED}${ITALIC}(BETA v0.1) 🛠️      ${RESET}"
echo ""

CONFIG_PATH="/home/user/ceremonyclient/node/.config/config.yml"

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
  sshpass -p "1" scp -o StrictHostKeyChecking=no "$temp_config" user@$ip:/tmp/cluster_config.yml

  SSH_COMMAND="
    sudo sed -i '/engine:/r /tmp/cluster_config.yml' $CONFIG_PATH &&
    sudo rm /tmp/cluster_config.yml
  "

  sshpass -p "1" ssh -o StrictHostKeyChecking=no user@$ip "$SSH_COMMAND"

  if [ $? -eq 0 ]; then
    echo -e ""
    echo -e "✅ Configuration mise à jour avec succès sur${BOLD} $ip.${RESET}"
  else
    echo -e ""
    echo -e "❌ Erreur : Échec de la mise à jour sur${BOLD} $ip.${RESET}"
  fi

  sudo rm -f "$temp_config"
}

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
  echo "sudo screen -dmS quil bash para.sh linux amd64 0 $master_threads 2.0.4"

  # Commandes pour les slaves
  local previous_threads=$((master_threads - 1)) # Threads pour le premier slave
  for i in "${!slaves_ips[@]}"; do
    local slave_ip="${slaves_ips[$i]}"
    echo -e ""
    echo -e "${YELLOW}Slave${RESET} ($slave_ip) :"
    echo "sudo screen -dmS quil bash para.sh linux amd64 $previous_threads $master_threads 2.0.4"
    # Mise à jour pour le prochain slave
    previous_threads=$((previous_threads + master_threads))
  done

}

generate_start_commands() {
  local threads=$1
  local master_ip=$2
  local slaves_ips=("${@:3}")

  master_command="sudo screen -dmS quil bash para.sh linux amd64 0 $threads 2.0.4"
  
  slave_commands=()
  slave_idx=1
  slave_threads=$((threads - 1))  # Slave 1 commence avec threads - 1
  
  for ip in "${slaves_ips[@]}"; do
    # Calculer les threads pour chaque slave
    slave_command="sudo screen -dmS quil bash para.sh linux amd64 $slave_threads $threads 2.0.4"
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
    for i in "${!slave_commands[@]}"; do
      slave_ip="${slaves_ips[$i]}"
      slave_command="${slave_commands[$i]}"
      echo ""
      echo -e "🟡 ${YELLOW}Exécution de la commande pour le slave sur ${BOLD}$slave_ip...${RESET}"
      echo ""
      sshpass -p "1" ssh -o StrictHostKeyChecking=no user@"$slave_ip" "cd /home/user/ceremonyclient/node && $slave_command"
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
    sshpass -p "1" ssh -o StrictHostKeyChecking=no user@"$master_ip" "cd /home/user/ceremonyclient/node && $master_command"
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

  # Début du contenu JSON
  local json_content="{\n"
  json_content+="  \"master_ip\": \"$master_ip\",\n"
  json_content+="  \"master_threads\": $master_threads,\n"
  json_content+="  \"slaves\": [\n"

  # Ajouter les IP des esclaves avec une virgule entre les éléments si plusieurs
  for i in "${!slaves_ips[@]}"; do
    # Si ce n'est pas la dernière IP, on ajoute une virgule
    if [ $i -lt $((${#slaves_ips[@]} - 1)) ]; then
      json_content+="    \"${slaves_ips[$i]}\",\n"
    else
      json_content+="    \"${slaves_ips[$i]}\"\n"
    fi
  done

  # Fin du contenu JSON
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

  # Validation JSON
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

# Menu principal
echo -e ""
echo -e "---------- ${CYAN}${BOLD}MENU PRINCIPAL${RESET}${RESET} ----------"
echo -e ""
echo -e "${BOLD}1.${RESET} ${YELLOW}Démarrer un cluster manuellement${RESET} ⚡"
echo -e "${BOLD}2.${RESET} ${YELLOW}Démarrer un cluster depuis un fichier de sauvegarde${RESET} 📄"
echo -e "${BOLD}3.${RESET} ${YELLOW}Configurer un nouveau cluster${RESET} 🔧"
echo ""
read -p "Veuillez choisir une option (1, 2 ou 3) : " choice

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

    read -p "Entrez un nom de configuration : " name_file

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

else
  echo -e "❌ ${RED} Choix invalide. Fermeture du script.${RESET}"
fi