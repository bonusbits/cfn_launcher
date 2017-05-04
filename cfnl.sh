#!/usr/bin/env bash

# Static Variables
successful=false
delete_successful=false
triggered_delete=false
script_version=1.7.0
# unset stack_name
# read -p "Enter Stack Name: " stack_name

function help_message () {
helpmessage="Description:
    This script uses the AWS CLI and BASH to create, update, delete or get
    status of a CloudFormation Stack. It uses the AWS CLI to push the
    CloudFormation Template to AWS. Then loops over and over checking
    status of the stack.

YAML Config File Format Example:
    stackname: stack1
    profilename: awsaccount
    region: us-west-2
    templateurl: https://s3.amazonaws.com/bucket/webapp1.yml # Or .json
    templatelocal: /path/to/cfn/templates/webapp1.yml # Unless using URL
    parametersfilepath: $HOME/.cfnl/uswest2/client1/account1/dev/webapp1.json
    capabilityiam: false
    capabilitynamediam: false
    deletecreatefailures: true
    uses3template: true
    nolog: false
    logfile: $HOME/.cfnl/logs/uswest2/client1/account1/dev/webapp1.log
    verbose: true
    waittime: 5
    maxwaits: 180

Examples:
    Create Stack
    $0 -f $HOME/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Update Stack
    $0 -u -f $HOME/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Delete Stack
    $0 -d -f $HOME/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Stack Status
    $0 -s -f $HOME/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Create Stack with Debugging
    $0 -b -f $HOME/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Delete Stack with Debugging
    $0 -d -b -f $HOME/.cfnl/uswest2/client1/account1/dev/webapp1.yml

Author:
    Levon Becker
    https://github.com/LevonBecker
    https://www.bonusbits.com
"
    usage
    echo "$helpmessage";
}

function version_message() {
versionmessage="CloudFormation Launcher v$script_version"
    echo "$versionmessage";
}

function usage() {
usagemessage="Usage: $0 [-u | -d | -s] -f ./config_file.yml

Options:
    -f File Path             :  (Required) YAML Script Config File Full Path
    -r Region                :  Overrides yaml config, ENV:AWS_REGION and aws config.
                                Set Order: 1. Parameter 2. Yaml Config 3. ENV:AWS_REGION 4. Default us-west-2
    -u Action Update         :  Action Flag to Update Stack
    -d Action Delete         :  Action Flag to Delete Stack
    -s Action Status         :  Action Flag to Get Stack Status
    -b Debug Output          :  Display Additional Output for Debugging
    -h Help                  :  Displays Help Information
    -v Version               :  Displays Script Version

Action Flags:
    Only one action flag can be used. The default Action is 'Create' (No flag).
    The three override Action Flags are -u, -d and -s.
"
    version_message
    echo ''
    echo "$usagemessage";
}

while getopts "f:r:bdhsuv" opts; do
    case $opts in
        b ) debug=true;;
        d ) delete=true;;
        f ) config_file_path=$OPTARG;;
        r ) opt_region=$OPTARG;;
        h ) help_message; exit 0;;
        s ) status=true;;
        u ) update=true;;
        v ) version_message; exit 0;;
    esac
done

action_flag_count=0
if [ -n "$delete" ]; then
    action_flag_count=$[$action_flag_count +1]
    flags_used+="-d "
fi
if [ -n "$update" ]; then
    action_flag_count=$[$action_flag_count +1]
    flags_used+="-u "
fi
if [ -n "$status" ]; then
    action_flag_count=$[$action_flag_count +1]
    flags_used+="-s "
fi
if [ "$action_flag_count" -gt 1 ]; then
    usage
    echo "ERROR: Multiple Action Flags detected! ($flags_used)"
    exit 1
fi

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

    # If just getting Status things like ACTION are not set, so need own header
	if [ "$status" == "true" ]; then
        message "ACTION: STATUS"
        message "CONFIG: ($config_file_path)"
        message "STACKNAME: ($yaml_stackname)"
	elif [ "$debug" == "true" ]; then
        message '** PARAMETERS **'
        message "ACTION: $ACTION"
        message "STACK NAME: $yaml_stackname"
        message "PROFILE: $yaml_profilename"
        message "REGION: $region"
        message "TEMPLATE: $TEMPLATE"
        message "PARAMETERS FILE: $yaml_parametersfilepath"
        message "CAPABILITY IAM: $yaml_capabilityiam"
        message "CAPABILITY NAMED IAM: $yaml_capabilitynamediam"
        message "NO LOG: $yaml_nolog"
        message "LOG FILE: $yaml_logfile"
        message "VERBOSE: $yaml_verbose"
        message "LAUNCHER CONFIG: $config_file_path"
        message "DELETE ON FAILURE: $yaml_deletecreatefailures"
        message "WAIT TIME (Sec): $yaml_waittime"
        message "MAX WAITS (Loops): $yaml_maxwaits"
	else
        message "ACTION: $ACTION"
        message "CONFIG: $config_file_path"
	fi
}

function exit_check {
    if [ "$triggered_delete" == "true" ]; then
        if [[ $1 -eq 0 || $1 -eq 255 ]]; then
            message "INFO: Successfully $2"
        else
            message "ERROR:  Exit Code $1 for $2"
            exit $1
        fi
    else
        if [ $1 -eq 0 ]; then
            message "INFO: Successfully $2"
        else
            message "ERROR:  Exit Code $1 for $2"
            exit $1
        fi
    fi
}

function create_logs_path {
    log_path=`dirname $yaml_logfile`

    if [ ! -d ${log_path} ]
    then
        if [ "$debug" == "true" ]; then
            message "DEBUG: Creating Logs Path Because Missing..."
            message "DEBUG: Logs Path ($log_path)"
        fi
        mkdir -p ${log_path}
        exit_check $? "Creating Logs Folder"
    fi
}

function set_region {
    if [ "$debug" == "true" ]; then
        message "DEBUG: Setting Region..."
    fi

    if [ -n "$opt_region" ]; then
       region="$opt_region"
    elif [ -n "$yaml_region" ]; then
       region="$yaml_region"
    elif [ -n "$AWS_REGION" ]; then
       region="$AWS_REGION"
    else
       region="us-west-2"
    fi

    if [ "$debug" == "true" ]; then
        message "DEBUG: Region ($region)"
    fi
}

function run_stack_command {
    # Determine if IAM Capabilities are Required
    if [ "$yaml_capabilityiam" == "true" ]; then
        capability_iam=" --capabilities CAPABILITY_IAM"
    elif [ "$yaml_capabilitynamediam" == "true" ]; then
        capability_iam=" --capabilities CAPABILITY_NAMED_IAM"
    else
        capability_iam=""
    fi

    show_header

    if [ "$yaml_uses3template" == "true" ]; then
        aws_command="aws cloudformation $task_type --profile $yaml_profilename --region $region --stack-name $yaml_stackname $capability_iam --template-url "$yaml_templateurl" --parameters file://$yaml_parametersfilepath"
    else
        aws_command="aws cloudformation $task_type --profile $yaml_profilename --region $region --stack-name $yaml_stackname $capability_iam --template-body file://$yaml_templatelocal --parameters file://$yaml_parametersfilepath"
    fi

    if [ "$debug" == "true" ]; then
        message "INFO: AWS Command ($aws_command)"
    fi

    $aws_command
    exit_check $? "Executed ${ACTION} Stack Command"
    echo ''

    monitor_stack_status
}

function delete_stack_command {
    message 'INFO: Deleting Stack'
    aws cloudformation delete-stack --profile ${yaml_profilename} --region ${region}  --stack-name ${yaml_stackname}
    exit_check $? "Executed Delete Stack Command"

    monitor_delete_stack_status
}

function output_create_complete {
    # If Verbose True then Output all the Create Complete Events for Debugging
    if [ "$yaml_verbose" == "true" ]; then
        message "INFO: CREATE COMPLETE EVENTS..."
        echo ''
        create_complete=$(aws cloudformation describe-stack-events --profile ${yaml_profilename} --region ${region}  --stack-name ${yaml_stackname} --output json --query 'StackEvents[?ResourceStatus==`CREATE_COMPLETE`]')
        message "$create_complete"
        echo ''
    fi
}

function output_create_failed {
    # Output all the Create Failed Events for Debugging
    message "INFO: CREATE FAILED EVENTS..."
    echo ''
    create_failed=$(aws cloudformation describe-stack-events --profile ${yaml_profilename} --region ${region}  --stack-name ${yaml_stackname} --output json --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]')
    message "$create_failed"
    echo ''
}

function monitor_delete_stack_status {
    triggered_delete=true
    wait_time=${yaml_waittime}
    max_waits=${yaml_maxwaits}
    while :
    do
        STATUS=$(aws cloudformation describe-stacks --profile ${yaml_profilename} --region ${region}  --stack-name "$yaml_stackname" --output text --query 'Stacks[*].StackStatus')
        exit_code=$?
        exit_check ${exit_code} "Executing Status Check"
        if [ ${exit_code} -eq 255 ]; then
            message "STATUS: (DOES NOT EXIST)"
        else
            message "STATUS: (${STATUS})"
        fi

        if [[ "$STATUS" == "DELETE_IN_PROGRESS" && ${count} -lt ${max_waits} ]]; then
            message "INFO: Delete not complete!"
            message "INFO: Attempt $count of $max_waits."
            display_runtime
            message "INFO: Polling again in $wait_time seconds..."
            echo ''
            sleep ${wait_time}
            count=$(( count + 1 ))
        elif [ ${exit_code} -eq 255 ]; then
            delete_successful=true
            message "INFO: Stack Deleted ($yaml_stackname)"
            break
        else
            message 'ERROR: The stack delete has failed.'
            break
        fi
    done
}

function get_stack_status {
    STATUS=$(aws cloudformation describe-stacks --profile ${yaml_profilename} --region ${region} --stack-name "$yaml_stackname" --output text --query 'Stacks[*].StackStatus')
    if [ $? -eq 255 ]; then
        message "STATUS: (DOES NOT EXIST) OR (TOKEN EXPIRED)"
    else
        message "STATUS: ($STATUS)"
    fi
}

function monitor_stack_status {
    wait_time=${yaml_waittime}
    max_waits=${yaml_maxwaits}
    while :
    do
        STATUS=$(aws cloudformation describe-stacks --profile ${yaml_profilename} --region ${region} --stack-name "$yaml_stackname" --output text --query 'Stacks[*].StackStatus')
        exit_check $? "Executing Status Check"
        message "STATUS: ($STATUS)"
        elapsed=$(( ($(date +%s) - ${start_time}) / 60 ))

        if [[ "$STATUS" == "${ACTION}_IN_PROGRESS" && ${count} -lt ${max_waits} ]]; then
            message "INFO: $ACTION stack is not complete!"
            message "INFO: Attempt $count of $max_waits."
            display_runtime
            message "INFO: Polling again in $wait_time seconds..."
            echo ''
            sleep ${wait_time}
            count=$(( count + 1 ))
        elif [ "$STATUS" == "${ACTION}_COMPLETE" ]; then
            message "INFO: $ACTION Completed!"
            successful=true
            break
        elif [ "$STATUS" == "${ACTION}_FAILED" ]; then
            message "ERROR:  $ACTION Failed!"
        elif [ "$STATUS" == "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS" ]; then
            message 'INFO: Cleanup in Progress'
            message "INFO: Attempt $count of $max_waits."
            display_runtime
            message "INFO: Polling again in $wait_time seconds..."
            echo ''
            sleep ${wait_time}
            count=$(( count + 1 ))
        elif [ "$STATUS" == "ROLLBACK_IN_PROGRESS" ]; then
            # If Delete Stack on failures when Creating is True then Delete the Stack after grabbing Events
            if [[ "$task_type" == "create-stack" && "$yaml_deletecreatefailures" == "true" ]]; then
                message 'ERROR:  Failed and Rolling Back!'
                echo ''
                output_create_complete
                output_create_failed
                delete_stack_command
                break
            # Else Fetch Events, but do not Delete the Stack
            else
                output_create_complete
                output_create_failed
                message 'ERROR:  Failed and Rolling Back!'
                message "INFO: Rollback not complete!"
                message "INFO: Attempt $count of $max_waits."
                display_runtime
                message "Polling again in $wait_time seconds..."
                echo ''
                sleep ${wait_time}
                count=$(( count + 1 ))
            fi
        elif [ "$STATUS" == "DELETE_IN_PROGRESS" ]; then
            monitor_delete_stack_status
            break
        elif [ "$STATUS" == "ROLLBACK_COMPLETE" ]; then
            message "INFO: Rollback complete!"
            echo ''
            break
        else
            message 'ERROR: The stack has not create or update has failed.'
            echo ''
            break
        fi
    done
}

function display_runtime {
    elapsed_seconds="$(($(date +%s) - ${start_time}))"
    formatted_runtime=$(printf "%02d minutes %02d seconds\n" "$((elapsed_seconds/60%60))" "$((elapsed_seconds%60))")
    message "RUNTIME: ${formatted_runtime}"
}

# Start Line here so if debugging it's before running any functions.
message "** Start CloudFormation Launcher v$script_version **"
if [ "$debug" == "true" ]; then
    message "-- Debugging Enabled --"
fi

# Start Time
start_time=$(date +%s)

# Read Yaml Properties File
eval $(parse_yaml ${config_file_path} "yaml_")

# Create Logs Folder if Logging
if [ ! "$yaml_nolog" == "true" ]; then
    create_logs_path
fi

# Set AWS Region
set_region

# Run Loop
count=1
if [ "$status" == "true" ]; then
    show_header
    get_stack_status
elif [ "$delete" == "true" ]; then
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

# Footer
if [ "$status" == "true" ]; then
    echo ''
else
    # Runtime
    end_time=$(date +%s)
    echo ''
    message "ENDTIME: ($(date))"
    display_runtime
    echo ''

    # Results
    if [[ "$delete_successful" == "true" && "$ACTION" == "DELETE" ]]; then
        message "RESULTS: DELETE SUCCESS!"
        echo ''
        exit 0
    elif [ "$successful" == "true" ]; then
        message "RESULTS: $ACTION SUCCESS!"
        echo ''
        exit 0
    else
        message "ERROR: $ACTION FAILED!"
        echo ''
      exit 1
    fi
fi