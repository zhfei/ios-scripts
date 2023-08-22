#!/bin/sh
# 作用：根据build的Target平台,自动切换APP内嵌入的动态库类型
# 真机时使用真机framework, 模拟器时使用模拟器framework
 
 
willBeChangedFrameworkList=('UnityFramework' 'xxx')
frameworkSuffixFlag='framework'
simulatorFrameworkCacheDir='模拟器动态库'
iphoneosFrameworkCacheDir='真机动态库'
 
if [ "${PLATFORM_NAME}" == "iphonesimulator" ]; then
    for scheme in ${willBeChangedFrameworkList[@]}; do
        iphoneosFrameworkPath="${SRCROOT}/Framework/${scheme}.${frameworkSuffixFlag}"
        simulatorFrameworkPath="${SRCROOT}/Framework/${scheme}${simulatorFrameworkCacheDir}/${scheme}.${frameworkSuffixFlag}"
         
        simulatorFrameworkFromDirPath="${SRCROOT}/Framework/${scheme}${simulatorFrameworkCacheDir}"
        iphoneosFrameworkToDirPath="${SRCROOT}/Framework/${scheme}${iphoneosFrameworkCacheDir}"
         
        if [ ! -d ${iphoneosFrameworkToDirPath} ]; then
            mkdir ${iphoneosFrameworkToDirPath}
            cp -r ${iphoneosFrameworkPath} ${iphoneosFrameworkToDirPath}
            rm -rf ${iphoneosFrameworkPath}
            cp -r ${simulatorFrameworkPath} "${SRCROOT}/Framework/"
            rm -rf ${simulatorFrameworkFromDirPath}
        fi
        #cd ${SRCROOT}
    done
 echo "Running on simulator: --------"
else
     
    for scheme in ${willBeChangedFrameworkList[@]}; do
        simulatorFrameworkPath="${SRCROOT}/Framework/${scheme}.${frameworkSuffixFlag}"
        iphoneosFrameworkPath="${SRCROOT}/Framework/${scheme}${iphoneosFrameworkCacheDir}/${scheme}.${frameworkSuffixFlag}"
         
        iphoneosFrameworkFromDirPath="${SRCROOT}/Framework/${scheme}${iphoneosFrameworkCacheDir}"
        simulatorFrameworkToDirPath="${SRCROOT}/Framework/${scheme}${simulatorFrameworkCacheDir}"
   
        if [ ! -d ${simulatorFrameworkToDirPath} ]; then
            mkdir ${simulatorFrameworkToDirPath}
            cp -r ${simulatorFrameworkPath} ${simulatorFrameworkToDirPath}
            rm -rf ${simulatorFrameworkPath}
            cp -r ${iphoneosFrameworkPath} "${SRCROOT}/Framework/"
            rm -rf ${iphoneosFrameworkFromDirPath}
        fi
         
    done
 
 echo "Running on iphoneos: --------"
fi
