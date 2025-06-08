# Docker & Kubernetes Bash Autocomplete

Context-aware autocompletion for `docker`, `kubectl`, `helm`, and `docker-compose`, with support for dynamic flags, resource names, and namespaces.

## ✅ Features

- 🚀 `docker`: Autocompletion for commands, flags, and container names
- ☸️ `kubectl`: Suggests subcommands, resource types, and **dynamic namespaces**
- ⎈ `helm`: Lists charts from configured repos on `install`, `upgrade`
- 🐳 `docker-compose`: Completes services defined in `docker-compose.yml`

---

## 📦 Installation

Clone the repo and source the script in your `.bashrc`:

```bash
git clone https://github.com/YOUR_USERNAME/docker-kube-completion.git ~/.docker-kube-completion
echo 'source ~/.docker-kube-completion/completion.sh' >> ~/.bashrc
source ~/.bashrc
