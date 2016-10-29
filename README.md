# CloudFormation Launcher (CFNL) BASH Script

## Purpose
Used to launch CloudFormation Template from command line using AWS CLI commands.

It is designed to be reusable without having to make changes to the script. 
Simple use a default create YAML config or create you own custom YAML config file.

## Tested Environment
* macOS El Capitan 10.11.6
* AWS CLI v1.10.66

# Prerequisites
This has been test
* BASH Shell
* **tee** command installed
* Proxy configured for Shell
* AWS CLI installed and configured

## Usage
### Download Repo Locally
1. Open Terminal
2. Pull down this git repository locally
    1. ```git clone https://github.com/bonusbits/cfn_launcher.git /path/to/clone/```

### CFNL Config
1. Create new YAML file with the same content of one of the example configs
2. Replace values with custom values as desired
    
    **Example**
    
    ```yaml
    stackname: awsaccount-env-stack
    profilename: awsaccount
    templateurl: https://s3.amazonaws.com/cfn-bucket/stack-template.yml
    templatelocal: /path/to/cfnl_configs/stack1-template.yml # Not used because uses3template = true
    parametersfilepath: /path/to/template/parameters/awsaccount-region-env-stack-parameters.json
    iamaccess: true
    deletecreatefailures: false
    uses3template: true
    logfile: /path/to/where/you/want/logs/cfnl-awsaccount-region-env-stack.log
    verbose: true
    waittime: 5
    maxwaits: 180
    ```
    
### Run CFNL
1. Open Terminal
2. Change to this directory<br>
    ```bash
    cd /path/to/clone/cfn-launcher/
    ```
3. Run script and point to a config yaml file<br>
    ```bash
    # Create Stack
    /path/to/cfn_launcher/cfn-launcher.sh -c /path/to/cfnl_configs/my-launcher-config.yml
    # If created alias or symlink
    cfnl -c /path/to/cfnl_configs/my-launcher-config.yml
 
    # Update Stack
    /path/to/cfn_launcher/cfn-launcher.sh -u -c /path/to/cfnl_configs/my-launcher-config.yml
    # If created alias or symlink
    cfnl -u -c /path/to/cfnl_configs/my-launcher-config.yml
    ```

## Example Pathing Access Options
Here are some examples that can be used to allow access to the cfn-launcher script without needing to be in the repo as a working directory.
Any one of a combo of these options can make it simple to fire off without much effort.

1. Symlink the ruby script to a place in path<br>
    ```bash
     if [ ! -h "/usr/local/bin/cfnl" ]; then
       ln -s "/path/to/clone/cfn_launcher/cfn-launcher.sh" /usr/local/bin/cfnl
     fi
    ```
2. Create aliases for stacks configs<br>
    ```bash
    # Create Stack
    alias cfnl-create-stack1-uswest1="cfnl -c /path/to/cfnl_configs/stack1-uswest1.yml"
    alias cfnl-create-stack2-uswest1="cfnl -c /path/to/cfnl_configs/stack2-uswest1.yml"
    # Update Stack
    alias cfnl-update-stack1-uswest1="cfnl -u -c /path/to/cfnl_configs/stack1-uswest1.yml"
    alias cfnl-update-stack2-uswest1="cfnl -u -c /path/to/cfnl_configs/stack2-uswest1.yml"
    ```
The reason I show with a region suffix on the example configurations is because the cfnl config points to your CloudFormation Parameters that probably has region specifics. 
 Such as, VPC, Subnets, Security Groups, Access Keys, etc.
    
### Output Examples

```bash
./cfn-launcher.sh -c ../cloudformation/cfnl_configs/bonusbits-prd-bastion-uswest1.yml
```

#### Success
    -----------------------------------------------------------------------------------------------------------------------
    |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    -----------------------------------------------------------------------------------------------------------------------
    CloudFormation Launcher
    1.1.1_10-20-2016
    -----------------------------------------------------------------------------------------------------------------------
    PARAMETERS
    -----------------------------------------------------------------------------------------------------------------------
    STACK NAME:       bonusbits-prd-bastion
    PROFILE:          bonusbits
    TEMPLATE:         https://s3.amazonaws.com/bonusbits-public/cloudformation-templates/github/bastion.template
    PARAMETERS FILE:  ./bonusbits-prd-bastion.json
    ENABLE IAM:       true
    TASK TYPE:        create-stack
    LOG FILE:         /var/log/cfn-launcher/cfn-launcher.log
    VERBOSE:          true
    -----------------------------------------------------------------------------------------------------------------------
    
    {
        "StackId": "arn:aws:cloudformation:us-west-2:00000000000:stack/bonusbits-prd-bastion/37f98fa0-96e7-11e6-b5c9-50d6cd0dfcc6"
    }
    [2016-10-20_10:12:35] REPORT: Success Started Stack Command
    [2016-10-20_10:12:36] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:12:36] REPORT: Status (CREATE_IN_PROGRESS)
    [2016-10-20_10:12:36] REPORT: CREATE stack is not complete!
    [2016-10-20_10:12:36] REPORT: Attempt 1 of 180.
    [2016-10-20_10:12:36] REPORT: Polling again in 5 seconds...
    
    [2016-10-20_10:12:43] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:12:43] REPORT: Status (CREATE_IN_PROGRESS)
    [2016-10-20_10:12:43] REPORT: CREATE stack is not complete!
    [2016-10-20_10:12:43] REPORT: Attempt 2 of 180.
    [2016-10-20_10:12:43] REPORT: Polling again in 5 seconds...
    
    ...
    
    [2016-10-20_10:16:25] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:16:25] REPORT: Status (CREATE_IN_PROGRESS)
    [2016-10-20_10:16:25] REPORT: CREATE stack is not complete!
    [2016-10-20_10:16:25] REPORT: Attempt 37 of 180.
    [2016-10-20_10:16:25] REPORT: Polling again in 5 seconds...
    
    [2016-10-20_10:16:32] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:16:32] REPORT: Status (CREATE_COMPLETE)
    [2016-10-20_10:16:32] REPORT: CREATE Completed!
    
    [2016-10-20_10:16:32] ENDTIME: (Thu Oct 20 10:16:32 PDT 2016)
    [2016-10-20_10:16:32] RUNTIME: 3 minutes
    
    [2016-10-20_10:16:32] REPORT: SUCCESS!

#### Failure
    -----------------------------------------------------------------------------------------------------------------------
    |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    -----------------------------------------------------------------------------------------------------------------------
    CloudFormation Launcher
    1.1.1_10-20-2016
    -----------------------------------------------------------------------------------------------------------------------
    PARAMETERS
    -----------------------------------------------------------------------------------------------------------------------
    STACK NAME:       bonusbits-prd-bastion
    PROFILE:          bonusbits
    TEMPLATE:         https://s3.amazonaws.com/bonusbits-public/cloudformation-templates/github/bastion.template
    PARAMETERS FILE:  ./bonusbits-prd-bastion.json
    ENABLE IAM:       true
    TASK TYPE:        create-stack
    LOG FILE:         /var/log/cfn-launcher/cfn-launcher.log
    VERBOSE:          true
    -----------------------------------------------------------------------------------------------------------------------
    
    {
        "StackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/bonusbits-prd-bastion/3c98fcd0-96e7-17e6-9c84-80d5cd265c36"
    }
    [2016-10-20_10:05:33] REPORT: Success Started Stack Command
    [2016-10-20_10:05:34] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:05:34] REPORT: Status (CREATE_IN_PROGRESS)
    [2016-10-20_10:05:34] REPORT: CREATE stack is not complete!
    [2016-10-20_10:05:34] REPORT: Attempt 1 of 180.
    [2016-10-20_10:05:34] REPORT: Polling again in 5 seconds...
    
    [2016-10-20_10:05:41] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:05:41] REPORT: Status (CREATE_IN_PROGRESS)
    [2016-10-20_10:05:41] REPORT: CREATE stack is not complete!
    [2016-10-20_10:05:41] REPORT: Attempt 2 of 180.
    [2016-10-20_10:05:41] REPORT: Polling again in 5 seconds...
    
    ...
    
    [2016-10-20_10:07:57] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:07:57] REPORT: Status (CREATE_IN_PROGRESS)
    [2016-10-20_10:07:57] REPORT: CREATE stack is not complete!
    [2016-10-20_10:07:57] REPORT: Attempt 23 of 180.
    [2016-10-20_10:07:57] REPORT: Polling again in 5 seconds...
    
    [2016-10-20_10:08:03] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:08:03] REPORT: Status (ROLLBACK_IN_PROGRESS)
    [2016-10-20_10:08:03] ERROR: Failed and Rolling Back!
    
    # TODO: Add example
    
    [2016-10-20_10:08:07] ACTION: Deleting Stack
    [2016-10-20_10:08:09] REPORT: Success Deleting Stack Command
    [2016-10-20_10:08:10] REPORT: Success Loaded Status Check into Variable
    [2016-10-20_10:08:10] REPORT: Status (DELETE_IN_PROGRESS)
    [2016-10-20_10:08:10] REPORT: Delete not complete!
    [2016-10-20_10:08:10] REPORT: Attempt 24 of 180.
    [2016-10-20_10:08:10] Polling again in 5 seconds...
    
    
    [2016-10-20_10:08:15] ENDTIME: (Thu Oct 20 10:08:15 PDT 2016)
    [2016-10-20_10:08:15] RUNTIME: 2 minutes
    
    [2016-10-20_10:08:16] ERROR: FAILED!

## Troubleshooting
* Can not use underscores of hyphens in yaml properties file key names.
