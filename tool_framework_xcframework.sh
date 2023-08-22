#!/bin/sh
 
# 作用：创建xcframework
# 使用方法：sh tool_framework_xcframework.sh "AppRootPath"
 
paramNum=$#
AppRootPath=$1
readonly location=`pwd`
 
cd $AppRootPath
 
# 执行shell命令，查询当前目录下所有的*.xcodeproj文件
projPaths=$(find . -name *.xcodeproj)
projPath0=${projPaths[0]} # 获取第0个路径
projName=${projPath0##*/} # 获取xxx.xcproj工程名
onlyName=${projName%.*}   # 获取纯净的xxx工程名
 
# echo "$projPaths"
# echo "$projPath0"
# echo "$projName"
# echo "$onlyName"
 
 
 
 
xcodebuild archive \
    -scheme ${onlyName} \
    -sdk iphonesimulator \
    -archivePath "archives/ios_simulators.xcarchive" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO
 
 
 
xcodebuild archive \
    -scheme ${onlyName} \
    -sdk iphoneos \
    -archivePath "archives/ios_devices.xcarchive" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO
 
 
 
xcodebuild -create-xcframework \
    -framework archives/ios_devices.xcarchive/Products/Library/Frameworks/${onlyName}.framework \
    -framework archives/ios_simulators.xcarchive/Products/Library/Frameworks/${onlyName}.framework \
    -output build/${onlyName}.xcframework
