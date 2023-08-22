#!/bin/sh
 
# 作用：批量压缩APP项目中Asset下的所有png图片，并自动替换。可用于APP包瘦身。
# 使用方法：sh tool_project_batchZipPicture.sh AppRootPath项目根据路径
# 注意：压缩后的切图大小并不一定是打包后的切图大小
:<<EOF
在项目中通过压缩png切图进行减少APP包体积时，对应压缩后的切图，在打出包后，在包中的图可能又重新变大
原因是：
1.对应Asset Catalog下管理的切图资源，Xcode打包编译时会用actool工具处理图片，优化图片大小。
对于压缩后的产物，在Xcode编译打包后，被压缩的切图都会重新变大，包括：pngquant有损压缩和imageoptim无损压缩
2.关掉Xcode的PNG优化开关,也没有效果（设置Targets->Build Settings->Compress PNG Files为YES）。
3.可以采用将压缩后的切图放在一个单独的目录下，脱离Asset Catalog的管理，避免被压缩后的切图重新被优化大，这样与现在的主流图片资源管理方式不匹配。
EOF
 
# xcassets说明
:<<EOF
iOS开发中，如果使用了Images.xcassets管理图片，打包的时候会生成一个Assets.car文件，所有的图片都在这里面。如果想查看里面包含的图片，则需要工具来解压将Assets.car文件解包到指定文件夹
已知现有的工具有：cartool，AssetCatalogTinkerer
EOF
 
 
filterList=(".git" "Tests")
#filterFileList=(*.podspec)
 
targetAssetDir=".xcassets"
targetPicture=".imageset"
 
appContainPictureList=()
UnUsedPictureList=()
UsedPictureList=()
 
totalSizeBefore=0
totalSizeAfter=0
 
 
paramNum=$#
AppRootPath=$1
MachOFilePath=$2
readonly location=`pwd`
tempPath=""
 
pictureTotalCount=0
zipPictureTotalCount=0
 
 
 
function getAllImagePath() {
    searchPath=$1
     
    echo "查询根目录：${searchPath}"
    searchOneDir ${searchPath}
}
         
 
function searchOneDir(){
    cd $1
    path=`pwd`
    for item in `ls`; do
        if [[ -d "${path}/${item}" ]] && [[ ! "${filterList[@]}" =~ "${item}" ]]
        then
            if [[ "${item}" =~ "${targetPicture}" ]]
            then
            echo "${path}/${item}"
            echo "内部：$item"
                itemSub="${path}/${item}"
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
 
function zipImageset() {
    tmp="${location}/tmp"
    rm -rf $tmp
     
    if [ ! -d ${tmp} ]
    then
        mkdir $tmp
    fi
 
    for assertName in ${appContainPictureList[@]}; do
        cd $assertName
        for item in `ls`; do
            if [[ "$item" =~ ".png" ]]
            then
                (( pictureTotalCount+=1 ))
                itemSize=$(wc -c < ${item})
                #(())为shell的数学运算符
                (( totalSizeBefore+=itemSize ))
                       
                #可能会被Xcode的Assert Catelog还原回去
                pngquant --speed=1 --quality=70 --output "${tmp}/${item}" -- "${item}"
                #统计压缩后的结果
                itemZipSize=$(wc -c < "${tmp}/${item}")
                (( totalSizeAfter+=itemZipSize ))
                #替换原图片
                rm -rf ${item}
                cp "${tmp}/${item}" `pwd`
                 
                #强制直接覆盖
#                zipRes=$(pngquant --speed=1 --quality=100 --output="${item}" --force -- "${item}")
#                echo $zipRes
#                itemZipSize=$(wc -c < "${item}")
#                (( totalSizeAfter+=itemZipSize ))
     
                #压缩前后图片对比
                num=`echo "scale=3; ${itemZipSize} / ${itemSize}" | bc`
                echo "${assertName}/${item} - 原始大小：$(( itemSize / 1024 ))KB: 压缩后大小：$(( itemZipSize / 1024 ))KB - 压缩后剩余内容比：${num}%"
            fi
        done
    done
     
    cd ${tmp}
    for item in `ls`; do
        (( zipPictureTotalCount+=1 ))
    done
}
 
 
if [ $paramNum -lt 1 ]
then
   echo "请输入查询的项目根路径"
else
    echo "开始收集项目的包含的图片资源：${AppRootPath}"
    getAllImagePath ${AppRootPath}
 
    path=`~`
    echo "压缩所有切图：${path}"
    zipImageset
      
    echo "项目中总切图数：${pictureTotalCount}"
    echo "项目中压缩成功的切图数：${zipPictureTotalCount}"
      
    numberBefore=$((totalSizeBefore/1024/1024))
    numberAfter=$((totalSizeAfter/1024/1024))
    echo "工程中包含的图片资源原始总大小:${numberBefore}M"
    echo "工程中使用的图片资源压缩后的总大小:${numberAfter}M"
 
 
fi
