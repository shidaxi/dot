#!/usr/bin/env bash

alias kube_cluster_resource='kubectl get nodes | grep node | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''echo {} ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo '\'''

function dot_status_app_pods {
    app=${1}
    kubectl get po --all-namespaces -l app=${app} -o=jsonpath="
{range .items[*]}{.metadata.namespace}: {.metadata.name}
{range .status.containerStatuses[*]}  {.name}: ready[{.ready}], restartCount[{.restartCount}], state[{.state}]{'\n'}{end}
{end}"
    kubectl get po --all-namespaces -l app=${app} -o=jsonpath="
{range .items[*]}{.metadata.namespace}: {.metadata.name}
{range .spec.containers[*]}  {.name}: cpu[{.resources.requests.cpu}/{.resources.limits.cpu}], memory[{.resources.requests.memory}/{.resources.limits.memory}]{'\n'}{end}
{end}"
    kubectl top po --all-namespaces -l app=${app} --containers
}


function exec_one_app_pod {
    app=${1}
    cmd=${2:-sh}
    POD_NS=$(kubectl get pod --all-namespaces -l app=${app} -o jsonpath='{.items[0].metadata.name},{.items[0].metadata.namespace}')
    POD=$(${POD_NS}|cut -d, -f1)
    NS=$(${POD_NS}|cut -d, -f2)
    kubectl -n ${NS} exec -it ${POD} ${cmd}
}

function exec_one_failed_app_pod {
    app=${1}
    cmd=${2:-sh}
    POD_NS=$(kubectl get pod --all-namespaces -l app=${app} -o jsonpath='{.items[0].metadata.name},{.items[0].metadata.namespace}')
    POD=$(${POD_NS}|cut -d, -f1)
    NS=$(${POD_NS}|cut -d, -f2)
    kubectl -n ${NS} patch pod ${POD} -p '{"spec": {"restartPolicy": "Never"}}'
    kubectl -n ${NS} exec -it ${POD} ${cmd}
}

function dot_sh_one_app_pod {
    app=${1}
    exec_one_app_pod ${app} sh
}

function dot_bash_one_app_pod {
    app=${1}
    exec_one_app_pod ${app} bash
}

function dot_bash_one_app_pod {
    app=${1}
    exec_one_app_pod ${app} bash
}
