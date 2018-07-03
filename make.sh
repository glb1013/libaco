# Copyright 2018 Sen Han 00hnes@gmail.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

OUTPUT_DIR="./output"
CFLAGS="-g -O2 -Wall -Werror"
EXTRA_CFLAGS=""
OUTPUT_SUFFIX=""
CC="cc"

app_list='''
test_aco_tutorial_0
test_aco_tutorial_0
test_aco_tutorial_1
test_aco_tutorial_2
test_aco_tutorial_3 -lpthread
test_aco_tutorial_4
test_aco_tutorial_5
test_aco_tutorial_6
test_aco_synopsis
test_aco_benchmark
'''

OUTPUT_DIR="$OUTPUT_DIR""//file"
OUTPUT_DIR=`dirname "$OUTPUT_DIR"`

gl_trap_str=""

function error(){
    echo "error: $*" > /proc/self/fd/2
}

function assert(){
    if [ "0" -ne "$?" ]
    then
        error "$0:""$*"
        exit 1
    fi
}

function tra(){
    gl_trap_str="$gl_trap_str""$1"
    trap "$gl_trap_str exit 1;" INT
    assert "$LINENO:trap failed:$gl_trap_str:$1"
}

function untra(){
    trap - INT
    assert "$LINENO:untrap failed:$gl_trap_str:$1"
}

function build_f(){
    declare file
    declare cflags
    declare build_cmd
    echo "OUTPUT_DIR:    $OUTPUT_DIR"
    echo "CFLAGS:        $CFLAGS"
    echo "EXTRA_CFLAGS:  $EXTRA_CFLAGS"
    echo "OUTPUT_SUFFIX: $OUTPUT_SUFFIX"
    echo "$app_list" | grep -Po '.+$' | while read read_in
    do
        file=`echo $read_in | grep -Po "^[^\s]+"`
        cflags=`echo $read_in | sed -r 's/^\s*([^ ]+)(.*)$/\2/'`
        if [ -z "$file" ] 
        then
            continue  
        fi
        #echo "<$file>:<$cflags>:$OUTPUT_DIR:$CFLAGS:$EXTRA_CFLAGS:$OUTPUT_SUFFIX"
        build_cmd="$CC $CFLAGS $EXTRA_CFLAGS acosw.S aco.c $file.c $cflags -o $OUTPUT_DIR/$file$OUTPUT_SUFFIX"
        echo "    $build_cmd"
        $build_cmd
        assert "build fail"
    done
    assert "exit"
}

tra "echo;echo build has been interrupted"

# the matrix of the build config for later testing
# -m32 -DACO_CONFIG_SHARE_FPU_MXCSR_ENV -DACO_USE_VALGRIND
# 0 0 0
EXTRA_CFLAGS="" OUTPUT_SUFFIX="..no_valgrind.standaloneFPUenv" build_f
# 0 0 1
EXTRA_CFLAGS="-DACO_USE_VALGRIND" OUTPUT_SUFFIX="..valgrind.standaloneFPUenv" build_f
# 0 1 0
EXTRA_CFLAGS="-DACO_CONFIG_SHARE_FPU_MXCSR_ENV" OUTPUT_SUFFIX="..no_valgrind.shareFPUenv" build_f
# 0 1 1
EXTRA_CFLAGS="-DACO_CONFIG_SHARE_FPU_MXCSR_ENV -DACO_USE_VALGRIND" OUTPUT_SUFFIX="..valgrind.shareFPUenv" build_f
# 1 0 0
EXTRA_CFLAGS="-m32" OUTPUT_SUFFIX="..m32.no_valgrind.standaloneFPUenv" build_f
# 1 0 1
EXTRA_CFLAGS="-m32 -DACO_USE_VALGRIND" OUTPUT_SUFFIX="..m32.valgrind.standaloneFPUenv" build_f
# 1 1 0
EXTRA_CFLAGS="-m32 -DACO_CONFIG_SHARE_FPU_MXCSR_ENV" OUTPUT_SUFFIX="..m32.no_valgrind.shareFPUenv" build_f
# 1 1 1
EXTRA_CFLAGS="-m32 -DACO_CONFIG_SHARE_FPU_MXCSR_ENV -DACO_USE_VALGRIND" OUTPUT_SUFFIX="..m32.valgrind.shareFPUenv" build_f