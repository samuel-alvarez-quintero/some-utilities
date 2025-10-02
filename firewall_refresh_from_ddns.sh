#!/bin/bash
# Uso: update-ddns-ipset.sh <DOMINIO> <IPSET>
# Ejemplo: update-ddns-ipset.sh cygnus.ddns.net oficina-ddns

DOMAIN="$1"
IPSET="$2"

if [ -z "$DOMAIN" ] || [ -z "$IPSET" ]; then
  echo "Uso: $0 <DOMINIO> <IPSET>"
  exit 1
fi

# Resolver la IP actual del dominio
IP=$(dig +short "$DOMAIN" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)

if [ -z "$IP" ]; then
  echo "No se pudo resolver $DOMAIN"
  exit 1
fi

# Verificar si la IP ya está en el ipset
EXISTS=$(firewall-cmd --ipset="$IPSET" --get-entries 2>/dev/null | grep -Fx "$IP")

if [ -z "$EXISTS" ]; then
  echo "Actualizando $IPSET con $IP para $DOMAIN"

  # Limpiar entradas anteriores
  OLD_IPS=$(firewall-cmd --ipset="$IPSET" --get-entries 2>/dev/null)
  for OLD_IP in $OLD_IPS; do
    firewall-cmd --ipset="$IPSET" --remove-entry="$OLD_IP"
  done

  # Agregar nueva IP
  firewall-cmd --ipset="$IPSET" --add-entry="$IP"
else
  echo "$DOMAIN ya resuelve a $IP y está en $IPSET"
fi
