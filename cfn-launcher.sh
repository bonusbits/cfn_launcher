#!/bin/bash

# Static Variables
successful=false
delete_successful=false
triggered_delete=false
script_version=1.4.0
# unset stack_name
# read -p "Enter Stack Name: " stack_name

function help_message () {
helpmessage="
-----------------------------------------------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------
AUTHOR:       Levon Becker
PURPOSE:      Create, Update or Delete CloudFormation Stack.
VERSION:      $script_version
DESCRIPTION:  This script uses the AWS CLI and BASH to create, update or delete a CloudFormation Stack.
              It uses the AWS CLI to push the CloudFormation Template to AWS.
              Then loops over and over checking status of the stack.
-----------------------------------------------------------------------------------------------------------------------
YAML FILE FORMAT EXAMPLE
-----------------------------------------------------------------------------------------------------------------------
stackname: awsaccount-env-stack
profilename: awsaccount
templateurl: https://s3.amazonaws.com/cfn-bucket/stack-template.yml
templatelocal: /path/to/cfnl_configs/stack1-template.yml # Not used because uses3template = true
parametersfilepath: /path/to/template/parameters/awsaccount-region-env-stack-parameters.json
capabilityiam: true
capabilitynamediam: false
deletecreatefailures: false
uses3template: true
nolog: false
logfile: /path/to/where/you/want/logs/cfnl-awsaccount-region-env-stack.log
verbose: true
waittime: 5
maxwaits: 180
noheader: false
-----------------------------------------------------------------------------------------------------------------------
EXAMPLES
-----------------------------------------------------------------------------------------------------------------------
Create Stack
$0 -c /path/to/cfnl/configs/awsaccount-region-env-stack-cfnlconfig.yml

Update Stack
$0 -u -c /path/to/cfnl/configs/awsaccount-region-env-stack-cfnlconfig.yml

Delete Stack
$0 -d -c /path/to/cfnl/configs/awsaccount-region-env-stack-cfnlconfig.yml
"
    echo "$helpmessage";
}

function version_message() {
versionmessage="CloudFormation Launcher Version: $script_version"
    echo "$versionmessage";
}

function usage() {
usagemessage="
usage: $0 [-u] -c ./config_file.yml

-c Config File           :  YAML Script Config File Full Path (Required)
-u Update Stack          :  Triggers Update Operation (Default is Create Stack)
-d Update Stack          :  Triggers Deletion of Stack
-h Help                  :  Displays Help Information
"
    echo "$usagemessage";
}

while getopts "c:udvh" opts; do
    case $opts in
        c ) config_file_path=$OPTARG;;
        u ) update=true;;
        d ) delete=true;;
        v ) version_message; exit 0;;
        h ) help_message; exit 0;;
    esac
done

if [ "$config_file_path" == "" ]; then
usage
echo 'ERROR: A YAML Config File is Required!'
exit 1
fi

# Set Task Type
if [ "$update" == "true" ]; then
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
    if [ "$yaml_nolog" == "true" ]; then
        echo "[$DATETIME] $*"
    else
        echo "[$DATETIME] $*" | tee -a ${yaml_logfile}
    fi
}

function show_header {
    if [ "$yaml_uses3template" == "true" ]; then
        TEMPLATE=${yaml_templateurl}
    else
        TEMPLATE=${yaml_templatelocal}
    fi

    HEADER="
-----------------------------------------------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-----------------------------------------------------------------------------------------------------------------------
CloudFormation Launcher
v$script_version
-----------------------------------------------------------------------------------------------------------------------
PARAMETERS
-----------------------------------------------------------------------------------------------------------------------
ACTION:               $ACTION
STACK NAME:           $yaml_stackname
PROFILE:              $yaml_profilename
TEMPLATE:             $TEMPLATE
PARAMETERS FILE:      $yaml_parametersfilepath
CAPABILITY IAM:       $yaml_capabilityiam
CAPABILITY NAMED IAM: $yaml_capabilitynamediam
TASK TYPE:            $task_type
NO LOG:               $yaml_nolog
LOG FILE:             $yaml_logfile
VERBOSE:              $yaml_verbose
LAUNCHER CONFIG:      $config_file_path
DELETE ON FAILURE:    $yaml_deletecreatefailures
WAIT TIME (Sec):      $yaml_waittime
MAX WAITS (Loops):    $yaml_maxwaits
-----------------------------------------------------------------------------------------------------------------------
  "
	if [ "$yaml_noheader" == "true" ]; then
	    message ''
	else
		message "$HEADER"
	fi
}

function exit_check {
    if [ "$triggered_delete" == "true" ]; then
        if [[ $1 -eq 0 || $1 -eq 255 ]]; then
            message "REPORT: Successfully $2"
        else
            message "ERROR:  Exit Code $1 for $2"
            exit $1
        fi
    else
        if [ $1 -eq 0 ]; then
            message "REPORT: Successfully $2"
        else
            message "ERROR:  Exit Code $1 for $2"
            exit $1
        fi
    fi
}

function run_stack_command {
    # Determine if IAM Capabilities are Required
    if [ "$yaml_capabilityiam" == "true" ]; then
        capability_iam=" --capabilities CAPABILITY_IAM"
    elif [ "$yaml_capabilitynamediam" == "true" ]; then
        capability_iam=" --capabilities CAPABILITY_NAMED_IAM"
    else
        capability_iam=" "
    fi

    show_header

    if [ "$yaml_uses3template" == "true" ]; then
        aws cloudformation ${task_type} --profile ${yaml_profilename} \
                                        --stack-name ${yaml_stackname}${capability_iam} \
                                        --template-url "${yaml_templateurl}"  \
                                        --parameters file://${yaml_parametersfilepath}
    else
        aws cloudformation ${task_type} --profile ${yaml_profilename} \
                                        --stack-name ${yaml_stackname}${capability_iam} \
                                        --template-body file://${yaml_templatelocal}  \
                                        --parameters file://${yaml_parametersfilepath}
    fi
    exit_check $? "Executed ${ACTION} Stack Command"
    message ''

    monitor_stack_status
}

function delete_stack_command {
    message 'ACTION: Deleting Stack'
    aws cloudformation delete-stack --profile ${yaml_profilename} --stack-name ${yaml_stackname}
    exit_check $? "Executed Delete Stack Command"

    monitor_delete_stack_status
}

function output_create_complete {
    # If Verbose True then Output all the Create Complete Events for Debugging
    if [ "$yaml_verbose" == "true" ]; then
        message "REPORT: CREATE COMPLETE EVENTS..."
        message ''
        create_complete=$(aws cloudformation describe-stack-events --profile ${yaml_profilename} --stack-name ${yaml_stackname} --output json --query 'StackEvents[?ResourceStatus==`CREATE_COMPLETE`]')
        message "$create_complete"
        message ''
    fi
}

function output_create_failed {
    # Output all the Create Failed Events for Debugging
    message "REPORT: CREATE FAILED EVENTS..."
    message ''
    create_failed=$(aws cloudformation describe-stack-events --profile ${yaml_profilename} --stack-name ${yaml_stackname} --output json --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]')
    message "$create_failed"
    message ''
}

function monitor_delete_stack_status {
    triggered_delete=true
    wait_time=${yaml_waittime}
    max_waits=${yaml_maxwaits}
    while :
    do
        STATUS=$(aws cloudformation describe-stacks --profile ${yaml_profilename} --stack-name "$yaml_stackname" --output text --query 'Stacks[*].StackStatus')
        exit_code=$?
        exit_check ${exit_code} "Executing Status Check"
        message "REPORT: Status (${STATUS})"

        if [[ "$STATUS" == "DELETE_IN_PROGRESS" && ${count} -lt ${max_waits} ]]; then
            message "REPORT: Delete not complete!"
            message "REPORT: Attempt $count of $max_waits."
            message "Polling again in $wait_time seconds..."
            message ''
            sleep ${wait_time}
            count=$(( count + 1 ))
        elif [ ${exit_code} -eq 255 ]; then
            delete_successful=true
            message "REPORT: Stack Deleted ($yaml_stackname)"
            break
        else
            message 'ERROR: The stack delete has failed.'
            break
        fi
    done
}

function monitor_stack_status {
    wait_time=${yaml_waittime}
    max_waits=${yaml_maxwaits}
    while :
    do
        STATUS=$(aws cloudformation describe-stacks --profile ${yaml_profilename} --stack-name "$yaml_stackname" --output text --query 'Stacks[*].StackStatus')
        exit_check $? "Executing Status Check"
        message "REPORT: Status (${STATUS})"

        if [[ "$STATUS" == "${ACTION}_IN_PROGRESS" && ${count} -lt ${max_waits} ]]; then
            message "REPORT: $ACTION stack is not complete!"
            message "REPORT: Attempt $count of $max_waits."
            message "REPORT: Polling again in $wait_time seconds..."
            message ''
            sleep ${wait_time}
            count=$(( count + 1 ))
        elif [ "$STATUS" == "${ACTION}_COMPLETE" ]; then
            message "REPORT: $ACTION Completed!"
            successful=true
            break
        elif [ "$STATUS" == "${ACTION}_FAILED" ]; then
            message "ERROR:  $ACTION Failed!"
        elif [ "$STATUS" == "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS" ]; then
            message 'REPORT: Cleanup in Progress'
            message "REPORT: Attempt $count of $max_waits."
            message "REPORT: Polling again in $wait_time seconds..."
            message ''
            sleep ${wait_time}
            count=$(( count + 1 ))
        elif [ "$STATUS" == "ROLLBACK_IN_PROGRESS" ]; then
            # If Delete Stack on failures when Creating is True then Delete the Stack after grabbing Events
            if [[ "$task_type" == "create-stack" && "$yaml_deletecreatefailures" == "true" ]]; then
                message 'ERROR:  Failed and Rolling Back!'
                message ''
                output_create_complete
                output_create_failed
                delete_stack_command
                break
            # Else Fetch Events, but do not Delete the Stack
            else
                output_create_complete
                output_create_failed
                message 'ERROR:  Failed and Rolling Back!'
                message "REPORT: Rollback not complete!"
                message "REPORT: Attempt $count of $max_waits."
                message "Polling again in $wait_time seconds..."
                message ''
                sleep ${wait_time}
                count=$(( count + 1 ))
            fi
        elif [ "$STATUS" == "DELETE_IN_PROGRESS" ]; then
            monitor_delete_stack_status
            break
        elif [ "$STATUS" == "ROLLBACK_COMPLETE" ]; then
            message "REPORT: Rollback complete!"
            message ''
            break
        else
            message 'ERROR: The stack has not create or update has failed.'
            message ''
            break
        fi
    done
}

# Start Time
start_time=$(date +%s)
# Read Yaml Properties File
eval $(parse_yaml ${config_file_path} "yaml_")
#set | grep yaml_
count=1
if [ "$delete" == "true" ]; then
    ACTION=DELETE
    show_header
    delete_stack_command
else
    if [ "$task_type" == "create-stack" ]; then
        ACTION=CREATE
    elif [ "$task_type" == "update-stack" ]; then
        ACTION=UPDATE
    else
        ACTION=CREATE
    fi
    run_stack_command
fi

# End Time
end_time=$(date +%s)

# Results
message ''
message "ENDTIME: ($(date))"
elapsed=$(( (${end_time} - ${start_time}) / 60 ))
message "RUNTIME: ${elapsed} minutes"
message ''

if [[ "$delete_successful" == "true" && "$ACTION" == "DELETE" ]]; then
    message "REPORT: DELETE SUCCESS!"
    message ''
    exit 0
elif [ "$successful" == "true" ]; then
    message "REPORT: $ACTION SUCCESS!"
    message ''
    exit 0
else
    message "ERROR: $ACTION FAILED!"
    message ''
  exit 1
fi
