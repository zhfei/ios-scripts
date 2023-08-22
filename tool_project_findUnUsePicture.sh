#!/bin/sh
# 作用：查询项目中未被使用的图片
# 原理：收集项目中在Asset下所有的图片名称集合SetA, 查询MachO下的data,_cstring字段中所有使用的图片字符集合SetB, 然后让SetA - SetB 得到差集就是未使用的图片。
# 使用方法：sh tool_project_findUnUsePicture.sh 项目根路径
 
 
filterList=(".git" "xxx")
#filterFileList=(*.podspec)
 
targetAssetDir=".xcassets"
targetPicture=".imageset"
 
appContainPictureList=()
UnUsedPictureList=()
UsedPictureList=()
 
paramNum=$#
AppRootPath=$1
MachOFilePath=$2
 
 
function checkFileAndDir() {
    searchPath=$1
     
    echo "查询根目录：${searchPath}"
    searchOneDir ${searchPath}
}
         
 
function searchOneDir(){
    cd $1
    path=`pwd`
    for item in `ls`; do
        # echo "外部：$item"
        # echo "${path}/${item}"
        if [[ -d "${path}/${item}" ]] && [[ ! "${filterList[@]}" =~ "${item}" ]]
        then
            if [[ "${item}" =~ "${targetPicture}" ]]
            then
                echo "${path}/${item}"
                echo "内部：$item"
                itemSub=${item%.*}
                appContainPictureList+=(${itemSub})
            else
                if [[ -d ${item} ]]
                then
                    searchOneDir "$item"
                fi
            fi
        fi
    done
    cd ..
    path=`pwd`
    echo "path2: $path"
 
    return 0;
}
 
 
function checkMachOFile() {
    res=`strings $1`
 
    for assertName in ${appContainPictureList[@]}; do
        if [[ ! "$res" =~ "$assertName" ]]
        echo "$assertName"
        then
            UnUsedPictureList[${#UnUsedPictureList[*]}]=$assertName
        else
            UsedPictureList[${#UsedPictureList[*]}]=$assertName
        fi
    done
}
 
if [ $paramNum -lt 2 ]
then
   echo "请输入查询的项目根路径和MachO产物路径"
else
    echo "开始收集项目的包含的图片资源：${AppRootPath}"
    checkFileAndDir ${AppRootPath}
 
    echo "开始收集MachO中使用的图片资源：${MachOFilePath}"
    checkMachOFile ${MachOFilePath}
      
    echo "工程中包含的图片资源总个数:${#appContainPictureList[@]}"
    echo ${appContainPictureList[@]}
    echo "工程中未使用的图片资源:${#UnUsedPictureList[@]}"
    echo ${UnUsedPictureList[@]}
    echo "工程中使用的图片资源:${#UsedPictureList[@]}"
    echo ${UsedPictureList[@]}
 
 
fi
