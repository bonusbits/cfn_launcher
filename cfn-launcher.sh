#!/bin/bash

# !! WIP !!

# Static Variables
successful=false
script_version=1.2.1-20161024
# unset stack_name
# read -p "Enter Stack Name: " stack_name

function help_message () {
helpmessage="
-----------------------------------------------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------
AUTHOR:       Levon Becker
PURPOSE:      Create or Update CloudFormation Stack with CloudFormation Template.
VERSION:      $script_version
DESCRIPTION:  This script uses the AWS CLI and BASH to create or update a CloudFormation Stack.
              It uses the AWS CLI to push the CloudFormation Template to AWS.
              Then loops over and over checking status of the stack.
-----------------------------------------------------------------------------------------------------------------------
YAML FILE FORMAT EXAMPLE
-----------------------------------------------------------------------------------------------------------------------
stackname: My Bastion Stack
profilename: my_aws_cli_profile
templateurl: https://s3.amazonaws.com/bonusbits-public/cloudformation-templates/github/bastion.template
templatelocal: ../cloudformation/templates/bastion.template # Not used because uses3template = true
parametersfilepath: ../cloudformation/parameters/bonusbits-prd-bastion.json
iamaccess: true
deletecreatefailures: false
uses3template: true
logfile: /var/log/cfn_launcher/cfn-launcher.log
verbose: true
-----------------------------------------------------------------------------------------------------------------------
EXAMPLES
-----------------------------------------------------------------------------------------------------------------------
Create Stack
$0 -c /path/to/script/configs/bonusbits-prd-bastion.yml

Update Stack
$0 -u -c /path/to/script/configs/bonusbits-prd-bastion.yml
"
    echo "$helpmessage";
}

function usage() {
usagemessage="
usage: $0 [-u] -c ./config_file.yml

-c Config File           :  YAML Script Config File Full Path (Required)
-u Update Stack          :  Triggers Update Operation (Default is Create Stack)
-h Help                  :  Displays Help Information
"
    echo "$usagemessage";
}

while getopts "c:uh" opts; do
    case $opts in
        c ) config_file_path=$OPTARG;;
        u ) update=true;;
        h ) help_message; exit 0;;
    esac
done

if [[ ${config_file_path} == "" ]]; then
    usage
    echo 'ERROR: A YAML Config File is Required!'
    exit 1
fi

# Set Task Type
if [ ${update} == 'true' ]; then
    task_type=update-stack
else
    task_type=create-stack
fi

function parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function message() {
  DATETIME=$(date +%Y-%m-%d_%H:%M:%S)
  echo "[$DATETIME] $*" | tee -a ${yaml_logfile}
}
# TODO: Combine these two functions and use arg to switch modes
function message_nofile() {
  DATETIME=$(date +%Y-%m-%d_%H:%M:%S)
  echo "[$DATETIME] $*"
}

function show_header {
  if [ ${yaml_uses3template} == "true" ]; then
    TEMPLATE=${yaml_templateurl}
  else
    TEMPLATE=${yaml_templatelocal}
  fi

  HEADER="
-----------------------------------------------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------
CloudFormation Launcher
$script_version
-----------------------------------------------------------------------------------------------------------------------
PARAMETERS
-----------------------------------------------------------------------------------------------------------------------
STACK NAME:       $yaml_stackname
PROFILE:          $yaml_profilename
TEMPLATE:         $TEMPLATE
PARAMETERS FILE:  $yaml_parametersfilepath
ENABLE IAM:       $yaml_iamaccess
TASK TYPE:        $task_type
LOG FILE:         $yaml_logfile
VERBOSE:          $yaml_verbose
LAUNCHER CONFIG:  $config_file_path
-----------------------------------------------------------------------------------------------------------------------
  "
	echo "$HEADER" | tee -a ${yaml_logfile};
}

function exit_check {
	if [ $1 -eq 0 ]
	then
		message "REPORT: Success $2" | tee -a ${yaml_logfile}
	else
		message "ERROR: Exit Code $1 for $2" | tee -a ${yaml_logfile}
		exit $1
	fi
}
# TODO: Combine these two functions and have arg switch mode
function exit_check_nolog {
	if [ $1 -eq 0 ]
	then
		message_nofile "REPORT: Success $2"
	else
		message_nofile "ERROR: Exit Code $1 for $2"
		exit $1
	fi
}

function run_stack_command {
    # Determine if IAM Capabilities are Required
    if [ ${yaml_iamaccess} == "true" ]
    then
      capability_iam=" --capabilities CAPABILITY_IAM"
    else
      capability_iam=" "
    fi

    show_header

    if [ ${yaml_uses3template} == "true" ]; then
        aws cloudformation ${task_type} --profile ${yaml_profilename} \
                                        --stack-name ${yaml_stackname}${capability_iam} \
                                        --template-url "${yaml_templateurl}"  \
                                        --parameters file://${yaml_parametersfilepath}
    else
        aws cloudformation ${task_type} --profile ${yaml_profilename} \
                                        --stack-name ${yaml_stackname}${capability_am} \
                                        --template-body file://${yaml_templatelocal}  \
                                        --parameters file://${yaml_parametersfilepath}
    fi
    exit_check $? "Started Stack Command"
}

function delete_stack_command {
  message 'ACTION: Deleting Stack'
  aws cloudformation delete-stack --profile ${yaml_profilename} --stack-name ${yaml_stackname}
  exit_check $? "Deleting Stack Command"
}

function monitor_stack_status {
  # Poll for Status
  # wait_time 5, max_waits 180 = 15 minutes

  if [ ${task_type} == "create-stack" ]; then
    ACTION=CREATE
  elif [ ${task_type} == "update-stack" ]; then
    ACTION=UPDATE
  else
    ACTION=CREATE
  fi

  wait_time=5
  max_waits=180
  count=1
  delete_triggered=false
  while :
  do
    STATUS=$(aws cloudformation describe-stacks --stack-name "$yaml_stackname" --output text --query 'Stacks[*].StackStatus')
    exit_check $? "Loaded Status Check into Variable"
    message "REPORT: Status (${STATUS})"

    if [[ "$STATUS" == "${ACTION}_IN_PROGRESS" && ${count} -lt ${max_waits} ]]; then
      message "REPORT: ${ACTION} stack is not complete!"
      message "REPORT: Attempt $count of $max_waits."
      message "REPORT: Polling again in ${wait_time} seconds..."
      echo '' | tee -a ${yaml_logfile}
      sleep ${wait_time}
      count=$(( count + 1 ))
    elif [ "$STATUS" == "${ACTION}_COMPLETE" ]; then
      message "REPORT: ${ACTION} Completed!"
      successful=true
      break
    elif [ "$STATUS" == "${ACTION}_FAILED" ]; then
      message "ERROR: ${ACTION} Failed!"
      successful=false
    elif [ "$STATUS" == "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS" ]; then
      message 'REPORT: Cleanup in Progress'
      message "REPORT: Attempt $count of $max_waits."
      message "REPORT: Polling again in ${wait_time} seconds..."
      echo '' | tee -a ${yaml_logfile}
      sleep ${wait_time}
      count=$(( count + 1 ))
    elif [ "$STATUS" == "ROLLBACK_IN_PROGRESS" ]; then
      if [[ "$task_type" == "create-stack" && ${yaml_deletecreatefailures} == "true" ]]; then
        message 'ERROR: Failed and Rolling Back!'
        if [ ${yaml_verbose} == "true" ]; then
#            aws cloudformation describe-stack-events --stack-name ${yaml_stackname}
            aws cloudformation describe-stack-events --stack-name ${yaml_stackname} --query 'StackEvents[?ResourceStatus==`CREATE_COMPLETE`]'
            echo '' | tee -a ${yaml_logfile}
        fi
        aws cloudformation describe-stack-events --stack-name ${yaml_stackname} --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
        delete_stack_command
        successful=false
      else
        # So don't delete on update-stack
        if [ ${yaml_verbose} == "true" ]; then
#            aws cloudformation describe-stack-events --stack-name ${yaml_stackname}
           aws cloudformation describe-stack-events --stack-name ${yaml_stackname} --query 'StackEvents[?ResourceStatus==`CREATE_COMPLETE`]'
            echo '' | tee -a ${yaml_logfile}
        fi
        aws cloudformation describe-stack-events --stack-name ${yaml_stackname} --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
        message 'ERROR: Failed and Rolling Back!'
        message "REPORT: Rollback not complete!"
        message "REPORT: Attempt $count of $max_waits."
        message "Polling again in ${wait_time} seconds..."
        echo '' | tee -a ${yaml_logfile}
        sleep $wait_time
        count=$(( count + 1 ))
        successful=false
      fi
    elif [ ${STATUS} == "DELETE_IN_PROGRESS" ]; then
      message "REPORT: Delete not complete!"
      message "REPORT: Attempt ${count} of ${max_waits}."
      message "Polling again in ${wait_time} seconds..."
      echo '' | tee -a ${yaml_logfile}
      sleep ${wait_time}
      count=$(( count + 1 ))
      successful=false
      break
    elif [ ${STATUS} == "ROLLBACK_COMPLETE" ]; then
      message "REPORT: Rollback complete!"
      echo '' | tee -a ${yaml_logfile}
      successful=false
      break
    else
      message 'ERROR: The stack has not create or update has failed.'
      successful=false
      break
    fi
  done
}

# Start
#get_args
#validate_args
start_time=$(date +%s)
# Read Yaml Properties File
eval $(parse_yaml ${config_file_path} "yaml_")
#set | grep yaml_
run_stack_command
monitor_stack_status

# End Time
end_time=$(date +%s)

# Results
echo '' | tee -a ${yaml_logfile}
message "ENDTIME: ($(date))"
elapsed=$(( (${end_time} - ${start_time}) / 60 ))
message "RUNTIME: ${elapsed} minutes"
echo '' | tee -a ${yaml_logfile}

if [ "$successful" == "true" ]; then
  message "REPORT: SUCCESS!"
  exit 0
else
  message "ERROR: FAILED!"
  exit $1
fi
