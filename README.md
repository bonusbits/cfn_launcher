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
    * Unless set ```nolog: true``` in config
* Proxy configured for Shell if needed
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
    stackname: stack1
    profilename: awsaccount
    templateurl: https://s3.amazonaws.com/bucket/stack1.yml
    templatelocal: /path/to/cfn/templates/stack1.yml # Not used if uses3template: true
    parametersfilepath: /path/to/cfn/template/parameters/awsaccount-stack1-dev-uswest2.json
    capabilityiam: false
    capabilitynamediam: false
    deletecreatefailures: true
    uses3template: true
    nolog: false
    logfile: /path/to/where/you/want/logs/awsaccount-stack1-dev-uswest2.log
    verbose: true
    waittime: 5
    maxwaits: 180
    noheader: false
    ```

## Script Symlink and Aliases (Optional)
Here are some examples that can be used to allow access to the cfn-launcher script without needing to be in the repo as a working directory.
I generally like to create a symbolic link to the shell script in a standard accessable path that is already setup in the ```PATH``` environment variable. 
Then I create various aliases in my bash profile or aliases script to call the script with different configurations to make it quick and easy to call.
Yes these alias examples are long, but you can tab auto fill. 
Of course you can name the aliases whatever you want as long as there is not another command with the same name on the system. 
It could be as simple as cfc1, cfu1, cfd1, cfc2... or c-s1-uw2, u-s2-uw2, d-s2-uw2, c-s2-ue1... or cs1uw2, ds1uw2... etc. Whatever makes since to you...
Then the only challenge is if they are really short is remembering what each means.

### Symlink

```bash
 if [ ! -h "/usr/local/bin/cfnl" ]; then
   ln -s "/path/to/clone/cfn_launcher/cfn-launcher.sh" /usr/local/bin/cfnl
 fi
```
    
### Aliases

```bash
# Stack 1
alias cfnl-create-stack1-dev-uswest2-="cfnl -f /path/to/cfnl_configs/stack1-dev-uswest2.yml"
alias cfnl-update-stack1-dev-uswest2="cfnl -u -f /path/to/cfnl_configs/stack1-dev-uswest2.yml"
alias cfnl-delete-stack1-dev-uswest2="cfnl -d -f /path/to/cfnl_configs/stack1-dev-uswest2.yml"
alias cfnl-create-stack1-dev-useast1="cfnl -f /path/to/cfnl_configs/stack1-dev-useast1.yml"
alias cfnl-update-stack1-dev-useast1="cfnl -u -f /path/to/cfnl_configs/stack1-dev-useast1.yml"
alias cfnl-delete-stack1-dev-useast1="cfnl -d -f /path/to/cfnl_configs/stack1-dev-useast1.yml"
# Stack 2
alias cfnl-update-stack2-dev-uswest2="cfnl -u -f /path/to/cfnl_configs/stack2-dev-uswest2.yml"
alias cfnl-create-stack2-dev-uswest2="cfnl -f /path/to/cfnl_configs/stack2-dev-uswest2.yml"
alias cfnl-delete-stack2-dev-uswest2="cfnl -d -f /path/to/cfnl_configs/stack2-dev-uswest2.yml"
alias cfnl-update-stack2-dev-useast1="cfnl -u -f /path/to/cfnl_configs/stack2-dev-useast1.yml"
alias cfnl-create-stack2-dev-useast1="cfnl -f /path/to/cfnl_configs/stack2-dev-useast1.yml"
alias cfnl-delete-stack2-dev-useast1="cfnl -d -f /path/to/cfnl_configs/stack2-dev-useast1.yml"
```

**OR**

Or you could stip down all the entries to keep up with by doing something like this...

```bash
alias cf-c="cfnl -f "
alias cf-u="cfnl -u -f "
alias cf-d="cfnl -d -f "

alias stack1-dev-uswest2="/path/to/cfnl_configs/stack1-dev-uswest2.yml"
alias stack1-dev-useast1="/path/to/cfnl_configs/stack1-dev-useast1.yml"
alias stack2-dev-uswest2="/path/to/cfnl_configs/stack2-dev-uswest2.yml"
alias stack2-dev-useast1="/path/to/cfnl_configs/stack2-dev-useast1.yml"
```

Then Call create ```cf-c stack1-dev-uswest2``` update ```cf-u stack1-dev-uswest2``` delete ```cf-d stack1-dev-uswest2```
    
The reason I show with a region suffix on the example configurations is because the cfnl config points to your CloudFormation Parameters that probably has region specifics. 
 Such as, VPC, Subnets, Security Groups, Access Keys, etc.
 
Also, if you need to switch between AWS Accounts or update STS. That can be dropped in front of the CFNL call with ```&&``` separator. 
 
Example:
**aws-set** is function from somewhere that we wrote that sets environment variables for different AWS accounts.
**gentoken** is function from somewhere that we wrote that runs a script to update our AWS Secure Tokens.

```bash
alias cf-c="aws-set awsaccount-dev-uswest2 && gentoken && cfnl -f "
```
    
### Run CFNL
1. Open Terminal
2. Change to this directory

    ```bash
    cd /path/to/clone/cfn-launcher/
    ```
3. Run script and point to a config yaml file

    ```bash
    # Create Stack
    /path/to/cfn_launcher/cfn-launcher.sh -f /path/to/cfnl_configs/my-launcher-config.yml
    # If created alias or symlink
    cfnl -f /path/to/cfnl_configs/my-launcher-config.yml
 
    # Update Stack
    /path/to/cfn_launcher/cfn-launcher.sh -u -f /path/to/cfnl_configs/my-launcher-config.yml
    # If created alias or symlink
    cfnl -u -f /path/to/cfnl_configs/my-launcher-config.yml
    ```
    
### Output Examples

```bash
./cfn-launcher.sh -f ../cloudformation/cfnl_configs/bonusbits-prd-bastion-uswest1.yml
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
