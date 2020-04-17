
SET project="default"
echo "create service account monkey-ops in %project%"
oc project %project%
oc create serviceaccount  monkey-ops -n %project%
oc policy add-role-to-user edit system:serviceaccount:%project%:monkey-ops

 oc create -f ./openshift/monkey-ops-template.yaml -n %project%

oc new-app --name=monkey-ops-%project% --template=monkey-ops --param=APP_NAME=monkey-ops-%project% --param=INTERVAL=300 --param=MODE=background --param=PROJECT_NAME_CHAOS=%project% --labels=app_name=monkey-ops-%project% -n %project%
