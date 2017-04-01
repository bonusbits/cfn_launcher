# CloudFormation Launcher (CFNL) BASH Script

## Purpose
Used to launch CloudFormation Template from command line using AWS CLI commands.

It is designed to be reusable without having to make changes to the script. 
Simple use a default create YAML config or create you own custom YAML config file.

## Tested Environment
* macOS Sierra 10.12.3
* AWS CLI v1.11.55

## Prerequisites
This has been test
* BASH Shell
* **tee** command installed
    * Unless set ```nolog: true``` in config
* Proxy configured for Shell if needed
* AWS CLI installed and configured

## Setup
1. Open Terminal
2. Pull down this git repository locally
    1. ```git clone https://github.com/bonusbits/cfn_launcher.git /path/to/clone/```
3. Create symlink & aliases the the *cfnl.sh* as desired. Examples below.

    
## Help
The following can be displayed with the *-h* switch.
    
```
CloudFormation Launcher v1.6.0

Usage: /usr/local/bin/cfnl [-u | -d | -s] -f ./config_file.yml

Options:
    -f File Path             :  (Required) YAML Script Config File Full Path
    -u Update Stack          :  (Action Flag) Sets Action to Update Stack
    -d Delete Stack          :  (Action Flag) Sets Action to Delete Stack
    -s Stack Status          :  (Action Flag) Sets Action to Get Stack Status
    -b Debug Output          :  Display Additional Output for Debugging
    -h Help                  :  Displays Help Information
    -v Version               :  Displays Script Version

Action Flags:
    Only one action flag can be used. The default Action is 'Create'.
    The three override Action Flags are -u, -d and -s.

Description:
    This script uses the AWS CLI and BASH to create, update, delete or get
    status of a CloudFormation Stack. It uses the AWS CLI to push the
    CloudFormation Template to AWS. Then loops over and over checking
    status of the stack.

YAML Config File Format Example:
    stackname: stack1
    profilename: awsaccount
    templateurl: https://s3.amazonaws.com/bucket/webapp1.yml # Or .json
    templatelocal: /path/to/cfn/templates/webapp1.yml # Unless using URL
    parametersfilepath: /Users/levon/.cfnl/uswest2/client1/account1/dev/webapp1.json
    capabilityiam: false
    capabilitynamediam: false
    deletecreatefailures: true
    uses3template: true
    nolog: false
    logfile: /Users/levon/.cfnl/logs/uswest2/client1/account1/dev/webapp1.log
    verbose: true
    waittime: 5
    maxwaits: 180

Examples:
    Create Stack
    /usr/local/bin/cfnl -f /Users/levon/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Update Stack
    /usr/local/bin/cfnl -u -f /Users/levon/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Delete Stack
    /usr/local/bin/cfnl -d -f /Users/levon/.cfnl/uswest2/client1/account1/dev/webapp1.yml

    Stack Status
    /usr/local/bin/cfnl -s -f /Users/levon/.cfnl/uswest2/client1/account1/dev/webapp1.yml
```    
    
## Example BASH Profile Functions and Aliases
Examples BASH Profile scripts to simplify use, but are not required of course.

### .bash_profile
```bash
# CloudFormation Launcher Aliases
if [ -f $HOME/.bash_cfnl ]; then
	  source $HOME/.bash_cfnl
fi
```

### .bash_cfnl
```bash
#!/usr/bin/env bash

# CloudFormation Launcher - https://github.com/bonusbits/cfn_launcher

# Symlink
if [ ! -h "/usr/local/bin/cfnl" ]; then
   ln -s "$HOME/Development/github/bonusbits/cfn_launcher/cfnl.sh" /usr/local/bin/cfnl
fi

function cfnl-show() {
    echo "CFNL_PATH: ($CFNL_PATH)"
}

function cfnl-set-path() {
    cfnl_configs_path=$1

    export CFNL_PATH="$cfnl_configs_path"
    cfnl-show
}

# Default
cfnl-set-path $HOME/.cfnl/uswest2/client1/account01/prd/project01

function cfc() {
    #echo "Running Create Stack (/usr/local/bin/cfnl -f ${CFNL_PATH}/${1}.yml)"
    /usr/local/bin/cfnl -f "$CFNL_PATH/$1.yml"
}

function cfu() {
    #echo "Running Update Stack (/usr/local/bin/cfnl -u -f ${CFNL_PATH}/${1}.yml)"
    /usr/local/bin/cfnl -u -f "$CFNL_PATH/$1.yml"
}

function cfd() {
    #echo "Running Delete Stack (/usr/local/bin/cfnl -d -f ${CFNL_PATH}/${1}.yml)"
    /usr/local/bin/cfnl -d -f "$CFNL_PATH/$1.yml"
}

function cfs() {
    # echo "Running Stack Status (/usr/local/bin/cfnl -s -f ${CFNL_PATH}/${1}.yml)"
    /usr/local/bin/cfnl -s -f "$CFNL_PATH/$1.yml"
}
```

### Example Folder Structure
You can use whatever folder structure you like. This is just an example.

```
 $HOME/.cfnl/
└── uswest2
    └── client01
        └── account01
            ├── dev
            │   ├── project01
            │   │   └── efs.yml
            │   │   └── rds-snapshot.yml
            │   │   └── web.yml
            │   ├── shared
            │   │   └── vpc.yml
            │   │   └── utm.yml
            │   └── project02
            │       ├── efs.yml
            │       └── rds-snapshot.yml
            │       └── web.yml
            └── prd
                ├── project01
                │   ├── efs.yml
                │   ├── rds.yml
                │   └── web.yml
                ├── shared
                │   ├── vpc.yml
                │   └── utm.yml
                └── project02
                    ├── efs.yml
                    ├── rds.yml
                    ├── web-blue.yml
                    └── web-green.yml
```

### Example Aliased Commands
```bash
# Set CFNL Path
cfnl-set-path $HOME/.cfnl/uswest2/client01/account01/dev/project01
# CFNL is now set to use $HOME/.cfnl/uswest2/client01/account01/dev/project01/*.yml

# Create Stack
cfc web
# Delete Stack
cfd web
# Update Stack
cfu web
# Stack Status
cfs web
```
    
## Output Examples
### Create
    [2017-03-21_13:44:35] ** Start CloudFormation Launcher v1.6.0 **
    [2017-03-21_13:44:35] ACTION: CREATE
    {
        "StackId": "arn:aws:cloudformation:us-west-2:000000000000:stack/webapp1/32046180-0e78-11e7-86c8-513ac9841b19"
    }
    [2017-03-21_13:44:36] REPORT: Successfully Executed CREATE Stack Command
    
    [2017-03-21_13:44:37] REPORT: Successfully Executing Status Check
    [2017-03-21_13:44:37] REPORT: Status (CREATE_IN_PROGRESS)
    [2017-03-21_13:44:37] REPORT: CREATE stack is not complete!
    [2017-03-21_13:44:37] REPORT: Attempt 1 of 360.
    [2017-03-21_13:44:37] RUNTIME: 00 minutes 02 seconds
    [2017-03-21_13:44:37] REPORT: Polling again in 5 seconds...
    
    [2017-03-21_13:44:42] REPORT: Successfully Executing Status Check
    [2017-03-21_13:44:42] REPORT: Status (CREATE_IN_PROGRESS)
    [2017-03-21_13:44:42] REPORT: CREATE stack is not complete!
    [2017-03-21_13:44:42] REPORT: Attempt 2 of 360.
    [2017-03-21_13:44:42] RUNTIME: 00 minutes 07 seconds
    [2017-03-21_13:44:42] REPORT: Polling again in 5 seconds...
    
    [2017-03-21_13:44:48] REPORT: Successfully Executing Status Check
    [2017-03-21_13:44:48] REPORT: Status (CREATE_IN_PROGRESS)
    [2017-03-21_13:44:48] REPORT: CREATE stack is not complete!
    [2017-03-21_13:44:48] REPORT: Attempt 3 of 360.
    [2017-03-21_13:44:48] RUNTIME: 00 minutes 13 seconds
    [2017-03-21_13:44:48] REPORT: Polling again in 5 seconds...
    
    ... Fast Forward ...
    
    [2017-03-21_14:00:48] REPORT: Successfully Executing Status Check
    [2017-03-21_14:00:48] REPORT: Status (CREATE_IN_PROGRESS)
    [2017-03-21_14:00:48] REPORT: CREATE stack is not complete!
    [2017-03-21_14:00:48] REPORT: Attempt 172 of 360.
    [2017-03-21_14:00:48] RUNTIME: 16 minutes 13 seconds
    [2017-03-21_14:00:48] REPORT: Polling again in 5 seconds...
    
    [2017-03-21_14:00:54] REPORT: Successfully Executing Status Check
    [2017-03-21_14:00:54] REPORT: Status (CREATE_COMPLETE)
    [2017-03-21_14:00:54] REPORT: CREATE Completed!
    
    [2017-03-21_14:00:54] ENDTIME: (Tue Mar 21 14:00:54 PDT 2017)
    [2017-03-21_14:00:54] RUNTIME: 16 minutes 19 seconds
    
    [2017-03-21_14:00:54] REPORT: CREATE SUCCESS!

### Update
    [2017-03-21_14:11:10] ** Start CloudFormation Launcher v1.6.0 **
    [2017-03-21_14:11:10] ACTION: UPDATE
    {
        "StackId": "arn:aws:cloudformation:us-west-2:000000000000:stack/webapp1/32046180-0e78-11e7-86c8-513ac9841b19"
    }
    [2017-03-21_14:11:11] REPORT: Successfully Executed UPDATE Stack Command
    
    [2017-03-21_14:11:12] REPORT: Successfully Executing Status Check
    [2017-03-21_14:11:12] REPORT: Status (UPDATE_IN_PROGRESS)
    [2017-03-21_14:11:12] REPORT: UPDATE stack is not complete!
    [2017-03-21_14:11:12] REPORT: Attempt 1 of 360.
    [2017-03-21_14:11:12] RUNTIME: 00 minutes 02 seconds
    [2017-03-21_14:11:12] REPORT: Polling again in 5 seconds...
    
    [2017-03-21_14:11:17] REPORT: Successfully Executing Status Check
    [2017-03-21_14:11:17] REPORT: Status (UPDATE_IN_PROGRESS)
    [2017-03-21_14:11:17] REPORT: UPDATE stack is not complete!
    [2017-03-21_14:11:17] REPORT: Attempt 2 of 360.
    [2017-03-21_14:11:17] RUNTIME: 00 minutes 07 seconds
    [2017-03-21_14:11:17] REPORT: Polling again in 5 seconds...
    
    ... Fast Forward ...
    
    [2017-03-21_14:11:46] REPORT: Successfully Executing Status Check
    [2017-03-21_14:11:46] REPORT: Status (UPDATE_IN_PROGRESS)
    [2017-03-21_14:11:46] REPORT: UPDATE stack is not complete!
    [2017-03-21_14:11:46] REPORT: Attempt 7 of 360.
    [2017-03-21_14:11:46] RUNTIME: 00 minutes 36 seconds
    [2017-03-21_14:11:46] REPORT: Polling again in 5 seconds...
    
    [2017-03-21_14:11:52] REPORT: Successfully Executing Status Check
    [2017-03-21_14:11:52] REPORT: Status (UPDATE_COMPLETE)
    [2017-03-21_14:11:52] REPORT: UPDATE Completed!
    
    [2017-03-21_14:11:52] ENDTIME: (Tue Mar 21 14:11:52 PDT 2017)
    [2017-03-21_14:11:52] RUNTIME: 00 minutes 42 seconds
    
    [2017-03-21_14:11:52] REPORT: UPDATE SUCCESS!

### Status
    /Users/username/.cfnl/uswest2/client1/account01/prd/webapp1.yml
    Stack Status: (UPDATE_COMPLETE)
    
### Delete
    [2017-03-21_14:17:20] ** Start CloudFormation Launcher v1.6.0 **
    [2017-03-21_14:17:20] ACTION: DELETE
    [2017-03-21_14:17:20] ACTION: Deleting Stack
    [2017-03-21_14:17:21] REPORT: Successfully Executed Delete Stack Command
    [2017-03-21_14:17:21] REPORT: Successfully Executing Status Check
    [2017-03-21_14:17:21] REPORT: Status (DELETE_IN_PROGRESS)
    [2017-03-21_14:17:21] REPORT: Delete not complete!
    [2017-03-21_14:17:21] REPORT: Attempt 1 of 360.
    [2017-03-21_14:17:21] RUNTIME: 00 minutes 01 seconds
    [2017-03-21_14:17:21] Polling again in 5 seconds...
    
    [2017-03-21_14:17:27] REPORT: Successfully Executing Status Check
    [2017-03-21_14:17:27] REPORT: Status (DELETE_IN_PROGRESS)
    [2017-03-21_14:17:27] REPORT: Delete not complete!
    [2017-03-21_14:17:27] REPORT: Attempt 2 of 360.
    [2017-03-21_14:17:27] RUNTIME: 00 minutes 07 seconds
    [2017-03-21_14:17:27] Polling again in 5 seconds...
    
    ... Fast Forward ...
    
    [2017-03-21_14:18:54] REPORT: Successfully Executing Status Check
    [2017-03-21_14:18:54] REPORT: Status (DELETE_IN_PROGRESS)
    [2017-03-21_14:18:54] REPORT: Delete not complete!
    [2017-03-21_14:18:54] REPORT: Attempt 17 of 360.
    [2017-03-21_14:18:54] RUNTIME: 01 minutes 34 seconds
    [2017-03-21_14:18:54] Polling again in 5 seconds...
    
    [2017-03-21_14:19:00] REPORT: Successfully Executing Status Check
    [2017-03-21_14:19:00] REPORT: Status (DELETE_IN_PROGRESS)
    [2017-03-21_14:19:00] REPORT: Delete not complete!
    [2017-03-21_14:19:00] REPORT: Attempt 18 of 360.
    [2017-03-21_14:19:00] RUNTIME: 01 minutes 40 seconds
    [2017-03-21_14:19:00] Polling again in 5 seconds...
    
    
    An error occurred (ValidationError) when calling the DescribeStacks operation: Stack with id webapp1 does not exist
    [2017-03-21_14:19:06] REPORT: Successfully Executing Status Check
    [2017-03-21_14:19:06] REPORT: Status (DOES NOT EXIST)
    [2017-03-21_14:19:06] REPORT: Stack Deleted (webapp1)
    
    [2017-03-21_14:19:06] ENDTIME: (Tue Mar 21 14:19:06 PDT 2017)
    [2017-03-21_14:19:06] RUNTIME: 01 minutes 46 seconds
    
    [2017-03-21_14:19:06] REPORT: DELETE SUCCESS!

### Status
    /Users/username/.cfnl/uswest2/client1/account01/prd/webapp1.yml
    Stack Status: (DOES NOT EXIST)
    
## Troubleshooting
* Can not use underscores of hyphens in yaml properties file key names.
