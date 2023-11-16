#!/bin/bash
set -e

## Parameters
source_dir=${1?Source directory is required. Please pass as a parameter the absolute path to the directory of the source code to be tested.}
test_pkgs=${2?Test packages are required. Please pass as a parameter the packages to test.}
clear_TEST_RESULTS_DIRECTORY=${3:-false}
test_params=${4:-"-timeout 240s"}

## Variables
script_dir="$( dirname "${BASH_SOURCE[0]}" )"
initial_dir=$( pwd )

## Variables depending on sources
results_dir="$dest_dir/$TEST_RESULTS_DIRECTORY"

## Functions
show_help() {
    usageStr="
This script creates testresults for golang projects.
As a part of this, it does the following tasks.
    - Installs the following support modules if they are not already installed:
        - gotestsum
        - gcov2lcov
        - gocov
        - gocov-xml
    - Runs the tests
        - This creates the following files:
            - coverage.txt
            - jsongotest.log
            - testresults.xml
    - Generates the following test results (if the coverage.txt file was generated):
        - testresults/coverage.html
        - testresults/coverage.txt
        - testresults/lcov.info
        - testresults/coverage.cobertura.xml

Parameters:
    Source Directory              (required)              The absolute path to the directory of the source code to be tested
    Test Packages                 (required)              The list of packages to test
    Clear Test Results Directory  (default: false)        Controls whether or not any existing Test Results Directory is cleared
    Test Parameters               (default: timeout 240s) Additional test parameters to pass to the test wrapper

EXAMPLES:
    testresults.sh /path/to/go/project 'package1 package2 package3 package4' true
        - Executes tests related to packages 1-4 in the folder '/path/to/go/project' and clears the test results directory if it exists
    testresults.sh /path/to/go/project 'packageA packageB' false '-timeout 5s'
        - Executes tests related to packages A and B in the folder '/path/to/go/project', does not clear any existing test results directory, and passes the timeout parameter to the testing wrapper, with a timeout of 5 seconds.
"
    echo "$usageStr"
}

## Main
echo -e "\n------ Generating test results ------\n"

echo "Current working directory: $initial_dir"
echo "Script directory: $script_dir"
echo -e "Source directory: $source_dir\n"

# If any of the required modules are not installed, notify the user to install them
if [ -z $(command -v "gotestsum") ] || [ -z $(command -v "gotestsum") ] || [ -z $(command -v "gotestsum") ] || [ -z $(command -v "gotestsum") ]; then

    echo -e "\nPlease install the required modules and run this script again."
    echo -e "The script to install the missing modules can be found at $script_dir/install-go-modules.sh"
    exit 1

fi;

cd $source_dir

if [[ $clear_TEST_RESULTS_DIRECTORY = true ]] && [ -d "$TEST_RESULTS_DIRECTORY" ]; then
    echo -e "\nClearing test results directory\n"
    rm -rf $TEST_RESULTS_DIRECTORY
fi;

if [ ! -d "$TEST_RESULTS_DIRECTORY" ]; then
    echo -e "\nCreating test results directory\n"
    mkdir -p $TEST_RESULTS_DIRECTORY
fi;

echo -e "\n------ Running tests ------\n"
## coverage.txt format - https://github.com/golang/go/blob/0104a31b8fbcbe52728a08867b26415d282c35d2/src/cmd/cover/profile.go#L56
gotestsum --format standard-verbose --junitfile $TEST_RESULTS_DIRECTORY/testresults.xml --jsonfile $TEST_RESULTS_DIRECTORY/jsongotest.log -- -cover -coverprofile=$TEST_RESULTS_DIRECTORY/coverage.txt -covermode=atomic $test_params $test_pkgs | tee $TEST_RESULTS_DIRECTORY/testoutput.txt

echo -e "\n------ Generating coverage - lcov ------\n"
GOROOT=$(go env GOROOT) gcov2lcov -infile=$TEST_RESULTS_DIRECTORY/coverage.txt -outfile=$TEST_RESULTS_DIRECTORY/lcov.info

echo -e "------ Generating coverage - cobertura ------\n"
GOROOT=$(go env GOROOT) gocov convert $TEST_RESULTS_DIRECTORY/coverage.txt | gocov-xml > $TEST_RESULTS_DIRECTORY/coverage.cobertura.xml

echo -e "------ Generating coverage - html ------\n"
go tool cover -html=$TEST_RESULTS_DIRECTORY/coverage.txt -o $TEST_RESULTS_DIRECTORY/coverage.html

cd $initial_dir