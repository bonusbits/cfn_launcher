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
**!! Incomplete !!**

### Download Repo Locally
1. Open Terminal
2. Pull down this git repository locally
    1. ```git clone https://github.com/bonusbits/cfn_launcher.git /path/to/clone/```

### CFNL Config
1. Create new YAML file with the same content of one of the example configs
2. Replace values with custom values as desired
    <br>**Example**<br>
    ```yaml
    stackname: bonusbits-prd-bastion
    profilename: bonusbits
    templateurl: https://s3.amazonaws.com/bonusbits-public/cloudformation-templates/github/bastion.template
    templatelocal: ../cloudformation/templates/bastion.template # Not used because uses3template = true
    parametersfilepath: ../cloudformation/parameters/bonusbits-prd-bastion.json
    iamaccess: true
    deletecreatefailures: false
    uses3template: true
    logfile: /var/log/cfn_launcher/cfn-launcher.log
    verbose: true
    ```
    
### Run CFNL
1. Open Terminal
2. Change to this directory
    ```bash
    cd /path/to/clone/cfn-launcher/
    ```
3. Run script and point to a config yaml file
    ```bash
    ./cfn-launcher.sh -c ./my-config.yml
    ```
    
### Output Examples

```bash
./cfn-launcher.sh -c ../cloudformation/cfnl_configs/bonusbits-prd-bastion.yml
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

## Example Pathing Access Options
Here are some examples that can be used to allow access to the cfn-launcher script without needing to be in the repo as a working directory.
Any one of a combo of these options can make it simple to fire off without much effort.
* Create alias
    ```bash
    # Short Name for Script
    alias cfnl="/Users/username/cfn_launcher/cfn-launcher.sh"
    # Create Stack
    alias cfnl-bbprd-bastion-create="cfnl -c $HOME/cloudformation/cfnl_configs/bonusbits-prd-bastion.yml"
    # Update Stack
    alias cfnl-bbprd-bastion-create="cfnl -u -c $HOME/cloudformation/cfnl_configs/bonusbits-prd-bastion.yml"
    ```
* Symlink the ruby script to a place in path
    ```bash
    ln -s "/Users/username/cfn_launcher/cfn-launcher.sh" /usr/local/bin/cfn-launcher
    ```
* Add cloned repo path to environment path
    ```bash
    PATH="/Users/username/cfn-launcher:$PATH"
    ```

## Troubleshooting
* Can not use underscores of hyphens in yaml properties file key names.
