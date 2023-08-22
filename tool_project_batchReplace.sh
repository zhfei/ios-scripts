#!/bin/sh
 
# 作用：工程内递归扫描目标字符串，并打印出包含目标字符串的那一行的内容。也可以通过子命令r，进行设置批量替换新的字符串。
# 使用方法：查询命令[sh tool_project_batchReplace.sh s "pag"], 替换命令[sh tool_project_batchReplace.sh r "pag" "hello"]
# 子命令："s" #search
# 子命令："r" #replace
 
filterList=("Pods" "libs" "Scripts" "Makefile" "Podfile" "Podfile.lock" "readme.md" "LEGAL.md" "Assets.xcassets" "PerformanceTools" "xcshareddata" "xcuserdata" "build" "Images.xcassets" "Resources" "Products")
#filterFileList=(*.podspec)
 
# 如果没有输入cp参数，提示输入cp参数
paramNum=$#
subCmd=$1
param1=$2
param2=$3
readonly location=`pwd`
tempPath=""
subCmdValue1="s" #search
subCmdValue2="r" #replace
 
searchTotalCount=0
 
# 1.if判断
:<<EOF
-ne 比较数字 (numberic) ; != 比较字符 (string)
在比较时，数字和字符串用不同的比较符号，多条件使用|| 或者 &&
1.如果a>b且a<c
if (( a > b )) && (( a < c ))
或者
if [[ $a > $b ]] && [[ $a < $c ]]
或者
if [ $a -gt $b -a $a -lt $c ]
 
 
if (( a > b )); then
    ...
else
# 如果else里没有处理语句，则else不能写
fi
EOF
 
 
# 2.函数
:<<EOF
1、可以带function fun() 定义，也可以直接fun() 定义,不带任何参数。
2、参数返回，可以显示加：return 返回，如果不加，将以最后一条命令运行结果，作为返回值。 return 后跟数值n(0-255)
3、函数体内部，通过 $n 的形式来获取参数的值，例如，$1表示第一个参数，$2表示第二个参数，超过10个用${11}
funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}
funWithParam 1 2 3 4 5 6 7 8 9 34 73
 
结果：
第一个参数为 1 !
第二个参数为 2 !
第十个参数为 10 !
第十个参数为 34 !
第十一个参数为 73 !
参数总数有 11 个!
作为一个字符串输出所有参数 1 2 3 4 5 6 7 8 9 34 73 !
EOF
 
 
# ------------------search 查询-------------------
 
 
function checkFileAndDir() {
    searchPath=`pwd`
 
    # -iname：忽略大小写；-name：区分大小写；
    find ${searchPath} -iname $1
     
    echo "查询根目录：${searchPath}"
    items=`ls`
    #字符串转数组，将\n替换为空格
#    items=(${items//\n/ })
    echo $items
    index=0
    for item in `ls`; do
        index=`expr $index + 1`
        echo "\n++++++++开始查询第：${index}个项目,项目名称:${item}  ++++++++\n"
        searchOneDir $item
    done
}
         
 
function searchOneDir(){
    if [ -f ${1} ]; then
     
    # 缩小查询范围，减除不必要的查询
#        if [[ ${1} == *\.podspec || ${1} == *\.pbxproj || ${1} == *\.plist || ${1} == *\.sh ]]; then
#            return
#        fi
         
#        echo "查询 ${1}"
        res=$(sed -n "/${param1}/Ip" ${1}) #I:取消大小写
#        res=$(sed -n "/${param1}/p" ${1})
        # 非空判断
        if [ -n "$res" ]; then
            searchTotalCount=`expr $searchTotalCount + 1`
            echo "\n递归目录------结果个数：${searchTotalCount} --------：$1 ;"
            echo $res
        fi
         
    elif [ -d ${1} ];then
        #sed -i "" "s/OldName/NewName/g" grep -rl OldName ./
        #grep -rl： l列出文件内容符合条件的文件名， r递归查询
        #$(grep -rl ${param1} ./ | xargs sed -n "/${param1}/Ip")
         
        if [[ ! "${filterList[@]}" =~ "${1}" ]]
        then
            items=$(ls $1)
    #        echo "递归目录------结果个数：${searchTotalCount}--------：$1 ;"
            for item in ${items[@]}; do
    #        for ((i=0; i<${#items[@]}; i++)); do
    #            item=${items[i]}
 
                # [[ $filterList =~ $item ]]字符串包含：父字符串$tragetSchemes 是否包含子字符串$scheme ？
                # [[ "${filterList[@]}" =~ "$item" ]]数组包含：数组$"{filterList[@]}" 是否包含字符串"$item" ？
                # [[ ! "${filterList[@]}" =~ "$item" ]]数组不包含？
 
                if [[ ! "${filterList[@]}" =~ "$item" ]]
                then
    #                echo "进入：$item"
                    searchOneDir "$1/$item"
                fi
             done
        fi
    fi
    return 0;
}
 
 
# ------------------replace 替换-------------------
 
function scannerOneDir(){
    echo "${1}"
    if [ -f ${1} ]
    then
#        if [[ ${1} == *\.podspec || ${1} == *\.sh ]]; then
#            return
#        fi
         
        echo "替换 ${1}"
        sed -i "" "s/${param1}/${param2}/g" ${1}
        echo "替换成功"
    elif [ -d ${1} ]
    then
        #sed -i "" "s/OldName/NewName/g" grep -rl OldName ./
        $(grep -rl ${param1} ./ | xargs sed -i "" "s/${param1}/${param2}/g")
    fi
    return 0;
}
 
function handle() {
    if [ $subCmd == $subCmdValue1 ]; then
       searchOneDir $1;
    else
       scannerOneDir $1;
    fi
}
 
function handleDir() {
    # 进入到目标目录里，进行替换
    if [[ ! "${filterList[@]}" =~ "$1" ]]
    then
        if [[ ${1} == *\.podspec || ${1} == *\.sh ]]; then
            echo "匹配失败：${1}"
        else
            echo "匹配成功：${1}"
            handle ${1};
        fi
    else
        echo "匹配失败：${1}"
    fi
}
  
function scanDir(){
 
    res=`find . -name *.xcodeproj`
    echo $res
    if [[ ! ${res} ]]
    then
        # 扫描的是一个普通文件夹
        for item in `ls`; do
            handleDir ${item};
        done
    else
        # 扫描的是一个xcode项目父文件夹
        for path in ${res[@]}; do
            pathT=${path%.*}
            tempPath=${pathT%/*}
            projName=${pathT##*/}
            if [ ${projName} != "Pods" ]
            then
                echo "------进入项目根目录：${tempPath}, 入参：${param1}, ${param2}"
                cd ${tempPath}
                echo "projName： ${projName}"
                for item in `ls`; do
                    handleDir ${item};
                done
 
                cd ${location}
                echo "++++++退回Ant目录：${location}\n"
            fi
        done
    fi
    return 0;
}
 
 
 
# <<的用法:
# 当shell看到<<的时候，它就会知道下一个词是一个分界符。
# 在该分界符以后的内容都被当作输入，直到shell又看到该分界符(位于单独的一行)。
# 这个分界符可以是你所定义的任何字符串。
 
# EOF与<<结合:
# 通常将EOF与<<结合使用，表示后续的输入作为子命令或子Shell的输入，直到遇到EOF为止，再返回到主调Shell
 
# EOF特殊用法：
#EOF是（END Of File）的缩写，表示自定义终止符。既然自定义，那么EOF就不是固定的，可以随意设置别名，在linux按ctrl-d 就代表EOF。
#EOF一般会配合cat能够多行文本输出。
#其用法如下：
#<<EOF        #开始
#....         #输入内容
#EOF          #结束
 
#熟悉几个特殊符号:
#<：输入重定向
#>：输出重定向
#>>：输出重定向,进行追加,不会覆盖之前内容
#<<：标准输入来自命令行的一对分隔号的中间内容
 
# :<<COMMENTBLOCK
# shell脚本代码段
# COMMENTBLOCK
# 用来注释整段脚本代码。 :是shell中的空语句。
 
 
:<<EOF
shell 目录，文件判断
-f "file"   :  判断file是否是文件;
-d "file"  :  判断file是否是目录（文件夹）。
EOF
 
:<<EOF
xargs 将标准输入作为下一条命令的参数
$ echo "hello world" | xargs echo
hello world
上面的代码将管道左侧的标准输入，转为命令行参数hello world，传给第二个echo命令。
EOF
 
 
if [ $paramNum -lt 2 ]
then
   echo "请输入查询的字符串与要替换的新字符串"
else
    if [ $subCmd == $subCmdValue1 ]; then
        param1=$2
        param2=$3
        echo "开始查询：${param1}"
        checkFileAndDir ${param1}
    elif [ $subCmd == $subCmdValue2 ]; then
        param1=$2
        param2=$3
        echo "查询的字符串：${param1},要替换的新字符串：${param2}"
        scanDir
    else
        param1=$1
        param2=$2
        echo "查询的字符串：${param1},要替换的新字符串：${param2}"
        scanDir
    fi
     
fi
