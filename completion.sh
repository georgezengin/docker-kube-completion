#!/bin/bash

_docker_kube_custom_complete() {
    local cur prev words cword
    _init_completion || return

    local docker_cmds="build commit cp create diff events exec export history images import info inspect kill load login logout logs pause port ps pull push rename restart rm rmi run save search start stats stop tag top unpause update version volume"
    local docker_flags="--help --verbose --tls --tlsverify --config"
    local kube_cmds="apply attach auth autoscale certificate cluster-info completion config convert cordon cp create delete describe drain edit exec explain expose get label logs patch plugin port-forward proxy replace rollout run scale set top uncordon version"
    local kube_flags="--namespace -n --context --kubeconfig --help -o"

    local helm_cmds="install uninstall list upgrade repo search show create lint test rollback history pull template package plugin"
    local compose_cmds="build up down logs restart start stop exec run config ps top pull push"

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
