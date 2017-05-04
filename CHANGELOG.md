# CHANGE LOG

## 1.7.0 - 05/04/2017 - Levon Becker
* Added create log path if missing.
* Added aws region to be included in the aws cli calls
    * Added parameter to set region and override others
    * Added yaml config region: key/value check
    * Third option that is used for the region is to use ENV:AWS_REGION
    * Last is to default to a region us-west-2
    * When switching around between regions your .aws/config could be hard set to a region and is a headache to have to change the config when it's plenty easy to add as argument or just use ENV var so more dynamic.
* Renamed REPORT to INFO for logging
* Added some more debug messages
* Added status show_header section
* Moved start and add debug enable messages to be before any functions are run outside of show_header
* Remove Dev Null for Status check because apparently exit 255 can be that the stack doesn't exist, but also if your STS Token has expired.. lame that it's not a different exit code.

## 1.6.1 - 03/24/2017 - Levon Becker
* Added Config to regular header output

## 1.6.0 - 03/21/2017 - Levon Becker
* Added Stack Status Option
* Added Error Handling for multiple Action Flag Options
* Renamed Script from cfn-launcher.sh to cfnl.sh

## 1.5.1 - 11/15/2016 - Levon Becker
* Removed Task Type from header since Action replaces it.
* Move Display Runtime to Function so can be used during loops
* Improved Runtime output

## 1.5.0 - 11/15/2016 - Levon Becker
* Switched yaml parameter file argument from -c (config) to -f (file) So it doesn't get confused with "create"

## 1.4.0 - 11/15/2016 - Levon Becker
* Added Delete Stack switch argument and logic
* Added --profile to describe command
* Merged exit check functions
* Added delete triggered logic for exit check when the stack is removed a 255 will return
* Added no log option to yaml so log file write can be disabled
* Removed date & time from version
* Merged message functions
* Moved Action variable logic
* Added Action output to Header
* Added No Header Option

## 1.3.0 - 11/02/2016 - Levon Becker
* Renamed iamaccess to capabilityiam
* Added capabilitynamediam yaml config option

## 1.2.6 - 11/02/2016 - Stable - Levon Becker
* Added Version switch argument to display version

## 1.2.5 - 11/01/2016 - Stable - Levon Becker
* Added missing character in var for CAPABILITY_IAM

## 1.2.4 - 10/27/2016 - Stable - Levon Becker
* Added timeout count option for yaml config
* Fixed indents to 4 spaces
* Moved some of the loop logic to functions to reduce complexity

## 1.2.3 - 10/26/2016 - Stable - Levon Becker
* Fixed some conditions to be posix compliant

## 1.2.1 - 10/24/2016 - Stable - Levon Becker
* Added Help Message

## 1.2.0 - 10/24/2016 - Stable - Levon Becker
* Removed createstack property and made create stack default with -u switch to trigger update
* Fixed usage message

## 1.1.4 - 10/24/2016 - Stable - Levon Becker
* Fixed loop to work correctly with UPDATE_COMPLETE_CLEANUP_IN_PROGRESS status
* Fixed a couple strings that needed to be interpreted for console action status
* Changed script version

## 1.1.3 - 10/24/2016 - Levon Becker
* Changed argument switch to -c for config instead of -p for properties
* Updated Readme
* Created a create and update example config and moved to own directory

## 1.1.2 - 10/24/2016 - Levon Becker
* Fixed Header Logging to file
* Change binary name to hyphen instead of underscore

## 1.1.1 - 10/20/2016 - Levon Becker
* Added verbose option to get create complete outputs on fail so can track what worked and where it failed.

## 1.1.0 - 10/18/2016 - Stable - Levon Becker
* Added YAML Properties File Parser

## 1.1.2 - 10/17/2016 - Beta - Levon Becker
* WIP

## 1.0.1 - 10/14/2016 - Beta - Levon Becker
* WIP

## 1.0.0 - 10/13/2016 - Skeleton - Levon Becker
* Initial Commit

- - -