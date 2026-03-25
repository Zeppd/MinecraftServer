# .devcontainer/setup.sh
#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y ca-certificates apt-transport-https gnupg wget curl jq libxi6 libxtst6 libxrender1

wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list >/dev/null

sudo apt-get update
sudo apt-get install -y java-21-amazon-corretto-jdk

mkdir -p server
cd server

MC_VERSION="${MC_VERSION:-1.21.11}"
USER_AGENT="codespace-paper-setup/1.0"

BUILD_JSON="$(curl -fsSL -H "User-Agent: ${USER_AGENT}" "https://fill.papermc.io/v3/projects/paper/versions/${MC_VERSION}/builds")"
PAPER_URL="$(echo "$BUILD_JSON" | jq -r 'first(.[] | select(.channel=="STABLE") | .downloads."server:default".url) // empty')"

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
