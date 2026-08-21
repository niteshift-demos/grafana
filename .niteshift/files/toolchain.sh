# Installs the Go and Node versions the repository pins, and exports a PATH that
# resolves them. Sourced by .niteshift/setup and .niteshift/resume.

export PATH="/opt/node/bin:$PATH"

case "$(uname -m)" in
  aarch64 | arm64) go_arch=arm64 node_arch=arm64 ;;
  *) go_arch=amd64 node_arch=x64 ;;
esac

# The sandbox image ships Go under /usr/local/go but leaves it off PATH.
if ! command -v go > /dev/null 2>&1; then
  if [ ! -x /usr/local/go/bin/go ]; then
    go_version="$(awk '/^go [0-9]/ { print $2; exit }' go.mod)"
    curl -fsSL "https://go.dev/dl/go${go_version}.linux-${go_arch}.tar.gz" -o /tmp/go.tar.gz
    rm -rf /usr/local/go
    tar -xzf /tmp/go.tar.gz -C /usr/local
    rm -f /tmp/go.tar.gz
  fi
  ln -sf /usr/local/go/bin/go /usr/local/go/bin/gofmt /usr/local/bin/
fi

# The sandbox's system Node is older than the version Grafana pins.
node_version="$(tr -d 'v \n' < .nvmrc)"
if [ "$(node -v 2> /dev/null || true)" != "v${node_version}" ]; then
  curl -fsSL "https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-${node_arch}.tar.xz" -o /tmp/node.tar.xz
  rm -rf /opt/node
  mkdir -p /opt/node
  tar -xJf /tmp/node.tar.xz -C /opt/node --strip-components=1
  rm -f /tmp/node.tar.xz
fi

corepack enable
