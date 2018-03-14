#*******************************************************************************
#*   (c) 2018 ZondaX GmbH
#*
#*  Licensed under the Apache License, Version 2.0 (the "License");
#*  you may not use this file except in compliance with the License.
#*  You may obtain a copy of the License at
#*
#*      http://www.apache.org/licenses/LICENSE-2.0
#*
#*  Unless required by applicable law or agreed to in writing, software
#*  distributed under the License is distributed on an "AS IS" BASIS,
#*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#*  See the License for the specific language governing permissions and
#*  limitations under the License.
#********************************************************************************
#!/usr/bin/env bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)

handle_config()
{
    os_string="$(uname -s)"
    case "${os_string}" in
        Linux*)
            sudo apt-get install libusb-1.0.0 libudev-dev
            pip install --upgrade setuptools
            pip install -U ledgerblue ecpy==0.8.2
            ;;
        Darwin*)
            brew install libusb
            pip install --upgrade setuptools --user python
            pip install -U --no-cache ledgerblue ecpy==0.8.2 --user python
            ;;
        *)
            echo "OS not recognized"
            ;;
    esac

}

handle_make()
{
    # This function works in the scope of the container
    DOCKER_IMAGE=zondax/ledger-docker-bolos
    BOLOS_SDK=/project/deps/nanos-secure-sdk
    BOLOS_ENV=/opt/bolos
    JSMN_LIB=/project/deps/jsmn
    JSON_PARSER_LIB=/project/src/lib

    docker run -it --rm \
            -e JSMN_LIB=${JSMN_LIB} \
            -e JSON_PARSER_LIB=${JSON_PARSER_LIB} \
            -e BOLOS_SDK=${BOLOS_SDK} \
            -e BOLOS_ENV=${BOLOS_ENV} \
            -u `id -u` \
            -v $(pwd):/project \
            ${DOCKER_IMAGE} \
            make -C /project/src/ledger $1
}

handle_load()
{
    # This function works in the scope of the host
    export BOLOS_SDK=${SCRIPT_DIR}/deps/nanos-secure-sdk
    export BOLOS_ENV=/opt/bolos
    make -C ${SCRIPT_DIR}/src/ledger load
}

handle_delete()
{
    # This function works in the scope of the host
    export BOLOS_SDK=${SCRIPT_DIR}/deps/nanos-secure-sdk
    export BOLOS_ENV=/opt/bolos
    make -C ${SCRIPT_DIR}/src/ledger delete
}

case "$1" in
    make)       handle_make $2;;
    config)     handle_config;;
    load)       handle_load;;
    delete)     handle_delete;;
    upgrade)    handle_delete && handle_load;;
    *)
        echo "ERROR. Valid commands: make, config, load, delete"
        ;;
esac