#!/bin/bash

# Path to the keyword file
INI_FILE="$HOME/.docker-kube-completion/completion_keywords.ini"

# Default hardcoded fallbacks
default_docker_cmds="build commit cp create diff events exec export history images import info inspect kill load login logout logs pause port ps pull push rename restart rm rmi run save search start stats stop tag top unpause update version volume"
default_docker_flags="--help --verbose --tls --tlsverify --config"

default_kube_cmds="apply attach auth autoscale certificate cluster-info completion config convert cordon cp create delete describe drain edit exec explain expose get label logs patch plugin port-forward proxy replace rollout run scale set top uncordon version"
default_kube_flags="--namespace -n --context --kubeconfig --help -o"

default_helm_cmds="install uninstall list upgrade repo search show create lint test rollback history pull template package plugin"
default_compose_cmds="build up down logs restart start stop exec run config ps top pull push"

# Read comma-separated values from an ini section into space-separated strings
read_ini_values() {
    local section="$1"
    local key="$2"
    awk -F= -v section="[$section]" -v key="$key" '
        $0 == section { found=1; next }
        /^\[.*\]/     { found=0 }
        found && $1 ~ key {
            gsub(/[ \t]/, "", $2)
            gsub(/,/, " ", $2)
            print $2
            exit
        }
    ' "$INI_FILE"
}

# Load keyword lists with fallback
docker_cmds=$(read_ini_values docker commands)
docker_cmds="${docker_cmds:-$default_docker_cmds}"

docker_flags=$(read_ini_values docker flags)
docker_flags="${docker_flags:-$default_docker_flags}"

kube_cmds=$(read_ini_values kubectl commands)
kube_cmds="${kube_cmds:-$default_kube_cmds}"

kube_flags=$(read_ini_values kubectl flags)
kube_flags="${kube_flags:-$default_kube_flags}"

helm_cmds=$(read_ini_values helm commands)
helm_cmds="${helm_cmds:-$default_helm_cmds}"

compose_cmds=$(read_ini_values compose commands)
compose_cmds="${compose_cmds:-$default_compose_cmds}"

_docker_kube_custom_complete() {
    local cur prev words cword
    _init_completion || return

    case "${COMP_WORDS[0]}" in
        docker)
            if [[ "$prev" == "logs" || "$prev" == "exec" || "$prev" == "inspect" || "$prev" == "stop" || "$prev" == "rm" ]]; then
                local containers=$(docker ps -a --format '{{.Names}}')
                COMPREPLY=( $(compgen -W "$containers" -- "$cur") )
            elif [[ "$prev" == "docker" ]]; then
                COMPREPLY=( $(compgen -W "$docker_cmds $docker_flags" -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "$docker_flags" -- "$cur") )
            fi
            ;;
        kubectl)
            if [[ "$prev" == "get" || "$prev" == "describe" || "$prev" == "delete" ]]; then
                local resources="pods services deployments replicasets namespaces nodes configmaps secrets"
                COMPREPLY=( $(compgen -W "$resources" -- "$cur") )
            elif [[ "$prev" == "--namespace" || "$prev" == "-n" ]]; then
                local namespaces=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
                COMPREPLY=( $(compgen -W "$namespaces" -- "$cur") )
            elif [[ "$prev" == "kubectl" ]]; then
                COMPREPLY=( $(compgen -W "$kube_cmds $kube_flags" -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "$kube_flags" -- "$cur") )
            fi
            ;;
        helm)
            if [[ "$prev" == "install" || "$prev" == "upgrade" ]]; then
                local charts=$(helm search repo -o yaml | grep 'name:' | awk '{print $2}')
                COMPREPLY=( $(compgen -W "$charts" -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "$helm_cmds" -- "$cur") )
            fi
            ;;
        docker-compose)
            if [[ "$prev" == "up" || "$prev" == "restart" || "$prev" == "start" || "$prev" == "stop" ]]; then
                local services=$(grep '^\s\s[a-zA-Z0-9_-]*:' docker-compose.yml 2>/dev/null | sed 's/://g' | xargs)
                COMPREPLY=( $(compgen -W "$services" -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "$compose_cmds" -- "$cur") )
            fi
            ;;
    esac
}

complete -F _docker_kube_custom_complete docker
complete -F _docker_kube_custom_complete kubectl
complete -F _docker_kube_custom_complete helm
complete -F _docker_kube_custom_complete docker-compose
