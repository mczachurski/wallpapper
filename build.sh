#!/bin/bash

OUTPUT_DIR="output"
WALLPAPPER_DIR="Wallpapper.Objects"
WALLPAPPER_EXIF_DIR="WallpapperExif.Objects"
WALLPAPPER_LIB_DIR="WallpapperLib.Objects"
SRC_PATH="../../Sources"

if [ -d $OUTPUT_DIR ]; then
    echo "Remove output directory"
    rm -rf $OUTPUT_DIR
fi

echo "Create output directory [$OUTPUT_DIR]"
mkdir $OUTPUT_DIR

echo "Create wallpapper directory [$OUTPUT_DIR/$WALLPAPPER_DIR]"
mkdir $OUTPUT_DIR/$WALLPAPPER_DIR

echo "Create wallpapper exit directory [$OUTPUT_DIR/$WALLPAPPER_EXIF_DIR]"
mkdir $OUTPUT_DIR/$WALLPAPPER_EXIF_DIR

echo "Create wallpapper lib directory [$OUTPUT_DIR/$WALLPAPPER_LIB_DIR]"
mkdir $OUTPUT_DIR/$WALLPAPPER_LIB_DIR

cd $OUTPUT_DIR/$WALLPAPPER_LIB_DIR
echo "Compile WallpapperLib"

swiftc -c \
    $SRC_PATH/WallpapperLib/*.swift \
    $SRC_PATH/WallpapperLib/*/*.swift \
    $SRC_PATH/WallpapperLib/*/*/*.swift \
    -parse-as-library \
    -module-name WallpapperLib

swiftc \
    ${SRC_PATH}/WallpapperLib/*.swift \
    ${SRC_PATH}/WallpapperLib/*/*.swift \
    ${SRC_PATH}/WallpapperLib/*/*/*.swift \
    -emit-module \
    -module-name WallpapperLib

# compile Wallpapper
cd ../$WALLPAPPER_DIR

echo "Compile Wallpapper"

swiftc -c \
    ${SRC_PATH}/Wallpapper/*.swift \
    -I../$WALLPAPPER_LIB_DIR \
    -module-name wallpapper

cd ..

swiftc -emit-executable \
    $WALLPAPPER_LIB_DIR/*.o \
    $WALLPAPPER_DIR/*.o \
    -o wallpapper

# compile WallpapperExif
cd $WALLPAPPER_EXIF_DIR

echo "Compile WallpapperExif"

swiftc -c \
    ${SRC_PATH}/WallpapperExif/*.swift \
    -I../$WALLPAPPER_LIB_DIR \
    -module-name wallpapper_exif

cd ..

swiftc -emit-executable \
    $WALLPAPPER_LIB_DIR/*.o \
    $WALLPAPPER_EXIF_DIR/*.o \
    -o wallpapper-exif

cd ..
echo "All done"