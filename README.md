![Project Logo](./resources/images/chaosmonkey-OCP.png )

***

## What is this?

This is **Monkey-Ops:** a simple service implemented in Go which is deployed into a OpenShift V3 and V4 and generates some chaos within it. Monkey-Ops seeks some Openshift components like Pods or DeploymentConfigs and randomly terminates them.
**Basically, it's an implementation of Chaos Monkey using OpenShift's APIs.**

## Why Do this?

When you are implemented Cloud aware applications, these applications need to be designed so that they can tolerate the failure of services. Failures happen, and they inevitably happen when least desired, so the best way to prepare your application to fail is to test it in a chaos environment, and this is the target of Monkey-Ops.

Monkey-Ops is built to test the Openshift application's resilience, not to test the Openshift platform resilience.

## Why Not Chaos Monkey?

Chaos Monkey is designed to [wreck AWS applications](https://github.com/Netflix/SimianArmy/wiki/Quick-Start-Guide)
It does not understand OpenShift so we can't use it directly.

## How to use Monkey-Ops

Monkey-Ops is built to run in a docker image on openshift. Monkey-Ops also includes an Openshift template in order to be deployed into a Openshift Project.

Monkey-Ops has two different modes of execution: background or rest.

* **Background**: With the Background mode, the service is running nonstop until you stop the container.
* **Rest**: With the Rest mode, you consume an api rest that allows you login in Openshift, choose a project, and execute the chaos for a certain time.

The service accept parameters as flags or environment variables. These are the input flags required:

      --INTERVAL float        (application) Time interval between each actuation of operator monkey. It must be in seconds (by default 30)
      --MODE string           (application) Execution mode: background or rest (by default "background")
      --APP_NAME string       (template) name of application, usually "monkey-ops"
      --SA_NAME string        (template) name of service account set up with access to wreck project pods
      --TZ string             (template) time zone for running containers, defaulted to America/Detroit
      --PROJECT_NAME string   (template) name of project monkey will cause chaos in


### Usage with Openshift V3+


#### Setting it up to kill the project it runs in: The Easy Way
1. make sure the service account associated with your Jenkins master has access to Admin your project
2. Run the `monkey-go` job [here](https://jenkins-build.aoins.com/job/Build/job/OpenShift/job/monkey-go/) or run the Jenkinsfile on a different master.

#### Setting it up to kill the project it runs in: The Long Way
You'll need to **create a service account** with `edit` permissions within the project that you want to use. The service account is the `SA_NAME` parameter to the new-app template (monkey-ops-template.yml), by default `monkey-ops`.

(For more information, see [Managing Service Accounts](https://docs.openshift.org/latest/admin_guide/service_accounts.html#admin-managing-service-accounts))

First, create a service account called `monkey-ops`:

	$ oc create serviceaccount  monkey-ops -n "mah project"

Second, grant it the `edit` role:

	$ oc policy add-role-to-user edit system:serviceaccount:"mah project":monkey-ops -n "mah project"

**Deploy *monkey-ops-template.yaml* into your Openshift Project:**

	$ oc create -f ./openshift/monkey-ops-template.yaml -n "mah project"

**Create new  application monkey-ops into your Openshift Project:**

	$ oc new-app --name=monkey-ops --template=monkey-ops --param=PROJECT_NAME=<PROJECT_TO_RUN_IN> --param=APP_NAME=monkey-ops --param=INTERVAL=300 --param=MODE=background --labels=app_name=monkey-ops -n <PROJECT_TO_RUN_IN>

e.g.:

	$ oc new-app --name=monkey-ops --template=monkey-ops --param=PROJECT_NAME=util-user --param=APP_NAME=monkey-ops --param=INTERVAL=300 --param=MODE=background --labels=app_name=monkey-ops -n util-user

Once you have monkey-ops running in your project, you can see what the service is doing in youy application logs. i.e.

![Monkey-Ops logs](resources/images/logs.JPG)

**Time Zone**

By default this image uses the time zone "America/Detroit", if you want to change the default time zone, you should specify the environment variable TZ.

#### Building
Do this in case the docker image gets lost. You only need to do this if the image doesn't exist or needs to be rebuilt. The image exists in all OpenShift Corporate Clusters as of this writing.

	$ git https://bitbucket.aoins.com/scm/opsft/monkey-ops
	$ ./build.sh

### API REST

Monkey-Ops Api Rest expose two endpoints:

* **/login**

>This endpoint allows a user to log into Openshift in order to get a token and  projects to which it belongs.


>**Request Input JSON:**


>{
>     "user": "User name",
>     "password": "User password",
>     "url": "Openshift API Server URL. e.g. https://ose.api.server:8443"
> }

>**Request Output JSON:**

>	{
>     "token": "Token",
>     "projects": {
>    	 "project1 name",
>    	 "project2 name",
>    	 .
>    	 .
>    	 .
>    	 "projectN name"
>    	 }
>}	 


* **/chaos**

>This endpoint allows a user to launch the monkey-ops agent for a certain time.

>**Request Input JSON:**

>	{
>     "token": "Token",
>     "url": "Openshift API Server URL. e.g. https://ose.api.server:8443",
>     "project": "Project name",
>     "interval": Time interval between each actuation in seconds,
>     "totalTime": Total Time of monkey-ops execution in seconds
>	}
