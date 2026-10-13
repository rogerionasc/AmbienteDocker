#!/bin/bash

# Script para configurar os domínios locais no /etc/hosts do Ubuntu / Linux
# Uso: chmod +x setup-hosts.sh && ./setup-hosts.sh

DOMAINS=("appweb.local" "webclinic.local" "matriz.webclinic.local")
HOSTS_FILE="/etc/hosts"

echo "=========================================================="
echo "    Configuracao de DNS / Hosts Locais no Ubuntu (/etc/hosts)"
echo "=========================================================="

for domain in "${DOMAINS[@]}"; do
    if grep -q "[[:space:]]$domain" "$HOSTS_FILE"; then
        echo "[OK] $domain ja esta configurado em $HOSTS_FILE"
    else
        echo "[ADICIONANDO] 127.0.0.1 $domain"
        echo "127.0.0.1    $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
    fi
done

echo ""
echo "[SUCESSO] Configuracao concluida com sucesso!"
