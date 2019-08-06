freeStyleJob('deploy') {
  label('jnlp-slave')
  parameters {
    stringParam('STACK_NAME', 'uat-celery-ecs', 'stack name to be deployed to')
    stringParam('TAG', 'ken', 'name of the ken image tag which will get deployed to the above stack')
    booleanParam('CELERY_REFRESH', true, 'wether or not celery refresh should be restarted')
    booleanParam('MIGRATION', true, 'wether or not realize a migration of the database')
  }
  logRotator {
    numToKeep(100)
  }
  steps {
    shell('''#!/bin/bash
REVISION="2"
CLUSTER_NAME=${STACK_NAME}-${REVISION}
TASKROLE="arn:aws:iam::202279780353:role/nOpsRole"
echo "cluster name is ${CLUSTER_NAME}"

if [ $MIGRATION = true ]; then
  # looking for a best way to get the task definition
  TASK_DEFINITION=$(aws cloudformation describe-stacks  --region us-west-2  | jq ".Stacks | map(.Outputs[0].OutputValue) | map(select(. != null)) | map(select(contains(\\"${STACK_NAME}-MigrationTask\\")))[0]" | tr -d \\")
  TASK_DEFINITION=${TASK_DEFINITION#*/}
  TASK_DEFINITION=${TASK_DEFINITION%:*}
  CONTAINER_DEFINITIONS=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION --region us-west-2 | jq ".taskDefinition.containerDefinitions | map( .image = (.image | split(\\":\\"))[0] + \\":\\" + \\"${TAG}\\")")
	VOLUMES=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION --region us-west-2 | jq ".taskDefinition.volumes")
	TASK_ARN=$(aws ecs register-task-definition --task-role-arn $TASKROLE --region us-west-2 --family $TASK_DEFINITION --container-definitions "$CONTAINER_DEFINITIONS" --volumes "$VOLUMES" | jq ".taskDefinition.taskDefinitionArn")
	TASK_ARN=$(echo $TASK_ARN | tr -d \\")
  aws ecs run-task --cluster ${CLUSTER_NAME} --task-definition $TASK_ARN --count 1 --region us-west-2
fi

if [ $CELERY_REFRESH = true ]; then
  SERVICES=$(aws ecs list-services --region us-west-2 --cluster ${CLUSTER_NAME} | jq ".serviceArns[]" | cut -d "/" -f2 | tr -d \\")
else
   SERVICES=$(aws ecs list-services --region us-west-2 --cluster ${CLUSTER_NAME} | jq '.serviceArns[] | select(. | contains("WorkerRefresh") == false)' | cut -d "/" -f2 | tr -d \\")
fi

#Getting current desired count
declare -A COUNT
for SERVICE in ${SERVICES}
do
  COUNT["$SERVICE"]=$(aws ecs describe-services --region us-west-2 --cluster ${CLUSTER_NAME} --service $SERVICE | jq ".services[].deployments[] | select(.status == \\"PRIMARY\\") | .desiredCount")
done

#Scaling down
for SERVICE in ${SERVICES}
do
  if [ $(echo $SERVICE | grep -c KenService) == 0 -a  $(echo $SERVICE | grep -c kenStaticService) == 0 ]; then
  	echo "going to scale down this service ${SERVICE}"
  	aws ecs update-service --region us-west-2 --cluster ${CLUSTER_NAME} --service ${SERVICE} --desired-count 0
  elif [ $(echo $SERVICE | grep -c KenService) != 0 ] ; then
  	KEN=$SERVICE
  fi
done

echo updating tags
for SERVICE in ${SERVICES}
do
	#ecs deploy ${CLUSTER_NAME} ${SERVICE} -t ${TAG}
	TASK_ARN=$(aws ecs describe-services --region us-west-2 --cluster ${CLUSTER_NAME} --service $SERVICE | jq ".services[].taskDefinition")
	TASK_ARN=$(echo $TASK_ARN | tr -d \\")
	TASK_NAME=${TASK_ARN#*/}
	TASK_NAME=${TASK_NAME%:*}
	echo $TASK_NAME
	CONTAINER_DEFINITIONS=$(aws ecs describe-task-definition --task-definition $TASK_NAME --region us-west-2 | jq ".taskDefinition.containerDefinitions | map( .image = (.image | split(\\":\\"))[0] + \\":\\" + \\"${TAG}\\")")
	VOLUMES=$(aws ecs describe-task-definition --task-definition $TASK_NAME --region us-west-2 | jq ".taskDefinition.volumes")
	TASK_ARN=$(aws ecs register-task-definition --task-role-arn $TASKROLE --region us-west-2 --family $TASK_NAME --container-definitions "$CONTAINER_DEFINITIONS" --volumes "$VOLUMES" | jq ".taskDefinition.taskDefinitionArn")
	TASK_ARN=$(echo $TASK_ARN | tr -d \\")
	aws ecs update-service --region us-west-2 --cluster ${CLUSTER_NAME} --service $SERVICE --task-definition $TASK_ARN
done


#Scaling up
for SERVICE in ${SERVICES}
do
  if [ $(echo $SERVICE | grep -c KenService) == 0 -a  $(echo $SERVICE | grep -c kenStaticService) == 0 ]; then
  	SERVICE_NAME=$(echo $SERVICE | cut -d "-" -f4)
    DESIRED_COUNT=${COUNT["$SERVICE"]}
  	echo "going to scale up this service ${SERVICE}"
  	aws ecs update-service --region us-west-2 --cluster ${CLUSTER_NAME} --service $SERVICE --desired-count ${DESIRED_COUNT}
  fi
done

# shutting down a container for ken, to avoid lack of memory problems.
TASKS=$(aws ecs list-tasks --cluster $CLUSTER_NAME --service $KEN --region us-west-2 | jq '.taskArns[]'  | cut -d "/" -f2 | tr -d \\")
for TASK in ${TASKS}
do
  if [ $(aws ecs describe-tasks --tasks $TASK  --cluster $CLUSTER_NAME --region us-west-2 | jq .tasks[0].lastStatus | tr -d \\") == "RUNNING" ]; then
    echo "shutting First $KEN container in running status"
    aws ecs stop-task --task $TASK --cluster $CLUSTER_NAME --region us-west-2
    break
  fi
done
          ''')
  }
  publishers {
    slackNotifier {
      room('ken-dev')
      notifyAborted(true)
      notifyFailure(true)
      notifyNotBuilt(true)
      notifyUnstable(true)
      notifyBackToNormal(true)
      notifySuccess(true)
      notifyRepeatedFailure(false)
      startNotification(true)
      includeTestSummary(false)
      includeCustomMessage(true)
      customMessage('DEPLOYMENT TO $STACK_NAME, $JOB_NAME ON BUILD $BUILD_NUMBER')
      sendAs(null)
      commitInfoChoice('NONE')
      teamDomain('nclouds')
      buildServerUrl('')
      authToken('')
    }
  }
}
