#!/bin/sh
 
# 作用：手动符号化
# 使用方式：sh tool_bug_symbolCrash.sh CrashName.crash路径 AppName.app.dSYM路径
 
# 保存外部传参
paramNum=$#
crashPM1=$1
symbolPM2=$2
readonly location=`pwd`
tempPath=""
 
#1.增加环境变量
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
 
#2.查询符号化工具symbolicatecrash
tool=`find /Applications/Xcode.app/Contents -name symbolicatecrash -type f`
echo "查询到符号工具路径为：\n $tool"
 
#3.查询崩溃文件中UUID
uuid=`dwarfdump --uuid $symbolPM2`
echo "DSYM文件中UUID为：\n ${uuid}"
 
#4.符号化结果, crash文件路径 symbol符号路径先后顺序不能变
rm ~/Desktop/Result.crash
${tool} $crashPM1 $symbolPM2 > ~/Desktop/Result.crash
 
open ~/Desktop/Result.crash
