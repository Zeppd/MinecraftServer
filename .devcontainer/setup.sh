#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y ca-certificates apt-transport-https gnupg wget curl jq

# Install Java 21
sudo apt-get install -y openjdk-21-jdk

mkdir -p /workspaces/server
cd /workspaces/server

MC_VERSION="${MC_VERSION:-1.21.11}"
USER_AGENT="github-codespaces-minecraft-server/1.0 (your-email@example.com)"

BUILDS_JSON="$(curl -fsSL -H "User-Agent: ${USER_AGENT}" "https://fill.papermc.io/v3/projects/paper/versions/${MC_VERSION}/builds")"
PAPER_URL="$(echo "$BUILDS_JSON" | jq -r 'map(select(.channel=="STABLE")) | .[0].downloads."server:default".url // empty')"

if [ -z "$PAPER_URL" ]; then
  echo "Tidak ada stable build untuk versi ${MC_VERSION}"
  exit 1
fi

curl -fsSL -o paper.jar "$PAPER_URL"
printf "eula=true\n" > eula.txt

cat > start.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
java -Xms1G -Xmx2G -jar paper.jar --nogui
EOF

chmod +x start.sh
