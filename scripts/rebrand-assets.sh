#!/bin/bash
# ============================================================
# Exact-Ti Security Platform — Script de Rebranding de Assets
# Substitui logos e imagens Wazuh por Exact-Ti
# ============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_PATH="${1:-/usr/share/exactti-dashboard}"
ASSETS_PATH="$DASHBOARD_PATH/plugins/exactti/public/assets"

echo "🎨 Iniciando rebranding de assets Exact-Ti..."
echo "📁 Caminho do dashboard: $DASHBOARD_PATH"

# Criar diretório de assets Exact-Ti
mkdir -p "$ASSETS_PATH/custom/images"
mkdir -p "$DASHBOARD_PATH/ui/assets/exact-ti"

# Copiar logos Exact-Ti (devem estar na mesma pasta do script)
if [ -f "$SCRIPT_DIR/exact-ti-logo.svg" ]; then
  cp "$SCRIPT_DIR/exact-ti-logo.svg" "$ASSETS_PATH/custom/images/"
  cp "$SCRIPT_DIR/exact-ti-logo.svg" "$DASHBOARD_PATH/ui/assets/exact-ti/"
  echo "✅ Logo SVG copiado"
fi

if [ -f "$SCRIPT_DIR/exact-ti-mark.svg" ]; then
  cp "$SCRIPT_DIR/exact-ti-mark.svg" "$DASHBOARD_PATH/ui/assets/exact-ti/"
  echo "✅ Mark SVG copiado"
fi

# Substituir título no HTML principal
HTML_FILE="$DASHBOARD_PATH/ui/fonts/index.html"
if [ -f "$HTML_FILE" ]; then
  sed -i 's/<title>.*<\/title>/<title>Exact-Ti Security Platform<\/title>/g' "$HTML_FILE"
  echo "✅ Título HTML atualizado"
fi

# Substituir referências de produto em configs YAML
find "$DASHBOARD_PATH" -name "*.yml" -not -path "*/.git/*" \
  -exec sed -i 's/applicationTitle: .*/applicationTitle: "Exact-Ti Security Platform"/g' {} \;

# Substituir nomes de serviço
find /etc/systemd/system/ -name "wazuh*" 2>/dev/null | while read f; do
  newname=$(echo "$f" | sed 's/wazuh/exactti/g')
  cp "$f" "$newname"
  sed -i 's/Wazuh/Exact-Ti/g; s/wazuh/exactti/g' "$newname"
  echo "✅ Serviço renomeado: $(basename $newname)"
done

echo ""
echo "✅ Rebranding de assets concluído!"
echo "📋 Reinicie o serviço: systemctl restart exactti-dashboard"
