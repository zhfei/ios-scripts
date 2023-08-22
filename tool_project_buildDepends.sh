#!/bin/sh
 
# 作用：依赖编译，当一个项目下有多个在项目时，并多个在项目有编译依赖顺序，如：子项目A要比子项目B先编译，可以在下的排序列表中依次添加子项目，
#      添加的顺序就是它们的编译顺序。
# 使用方法：将脚本放在项目的根目录下，然后执行脚本[sh tool_project_buildDepends.sh 项目名称]
 
#模块层级依赖列表
sortSchemeNames=(AAA项目 BBB项目 CCC项目)
 
# -destination generic/platform=iOS \
# -destination generic/platform=iphonesimulator\
 
plateformDevice='generic/platform=iOS'
plateformSim='generic/platform=iphonesimulator'
 
#根据参数进行处理
paramNum=$#
param1=$1
readonly location=`pwd`
 
if [ $paramNum -lt 1 ]
then
    echo '--------请添加要编译的项目名称--------'
fi
 
$(rm -rf ~/Library/Developer/Xcode/DerivedData/${param1}*)
projectName="${param1}.xcodeproj"
projectPath=$(find . -name $projectName)
projectPath=${projectPath%/*}
cd $projectPath
 
 
projInfo=$(xcodebuild -list -project $projectName)
targetSchemes=${projInfo#*Schemes:}
echo "工程包含子项目有：${targetSchemes}"
 
# 遍历构建子项目
for ((i=0; i<${#sortSchemeNames[@]}; i++)); do
    scheme=${sortSchemeNames[i]}
    if [[ $targetSchemes =~ $scheme ]]
    then
        echo "------------构建开始：${scheme}"
        xcodebuild \
        -destination ${plateformDevice} \
        -workspace ${param1}.xcworkspace \
        -scheme ${scheme} \
        -configuration 'Debug'
        echo "++++++++++++构建结束：${scheme} \n"
    fi
done
 
cd $location
