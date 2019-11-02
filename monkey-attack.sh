#!/usr/bin/env bash 
# author : josh smith & lainie vyvyan

defaultproject=user1
if [ -z "$1" ]
  then
    project=${defaultproject}
else
    project="$1"
fi

#Setting up some colors for helping read the demo output
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

echo "{red}MONKEY ATTACK SCRIPT ${reset}"

echo  "${blue} 0. Verify OpenShift Login ${reset}"
oc whoami > /dev/null && echo "${cyan}*** IN BUSINESS AS: $(oc whoami) ***${reset}"

oc project ${project}

echo "${blue} 1. Build the docker image ${reset}"
./build.sh
oc tag monkey-ops:latest monkey-ops:stable

echo  "${blue} 2. create service account monkey-ops in ${project} ${reset}"
oc create serviceaccount  monkey-ops -n ${project}
oc policy add-role-to-user edit system:serviceaccount:${project}:monkey-ops

echo  "${blue} 3. Create template in ${project} ${reset}"
oc delete template monkey-ops
 oc create -f ./openshift/monkey-ops-template.yaml -n ${project}

echo  "${blue} 4. create new app  ${project} ${reset}"
oc delete all -l app=monkey-ops-${project} --wait

oc new-app --name=monkey-ops-${project} --template=monkey-ops --param=APP_NAME=monkey-ops-${project} --param=INTERVAL=300 --param=MODE=background --param=PROJECT_NAME=${project} --labels="app_name=monkey-ops-${project},chaos=monkey,app=monkey-ops-${project}" -n ${project}


