#!/bin/bash
#
# Copyright (c) 2018, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA Corporation and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA Corporation is strictly prohibited.
#

user="nvidia"
passwd="nvidia"


echo "** Install Dependency **"
sudo apt-get update
sudo apt-get install -y python-pip
sudo apt-get install -y libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk
sudo apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran
pip install -U pip
pip install --user dominate requests pillow scipy torchvision



echo "** Download source **"
git clone https://github.com/NVIDIA/vid2vid.git
cd vid2vid

sudo sed -i 's/==/>=/g' ./scripts/download_flownet2.py
if ! grep -q "#os.system" ./scripts/download_flownet2.py ; then
    sudo sed -i 's/os.system/#os.system/g' ./scripts/download_flownet2.py
fi

echo "download database ..."
python scripts/download_datasets.py
echo "download testing model ..."
python scripts/street/download_models.py
echo "download flow model ..."
python scripts/download_flownet2.py



echo "** Update for pyTorch1.0 & Xavier **"
cd models/flownet2_pytorch/networks
FILE=(./channelnorm_package/channelnorm_kernel.cu ./correlation_package/correlation_cuda.cc ./resample2d_package/resample2d_kernel.cu)

for f in "${FILE[@]}"; do
    if ! grep -q "#include <ATen/cuda/CUDAContext.h>" $f ; then
        sed -i '3i#include <ATen/cuda/CUDAContext.h>' $f
    fi
done



echo "** Build it from source **"
cd ../
install.sh



echo "** Test 2048 model **"
cd ../..
bash ./scripts/street/test_2048.sh


echo "** Byebye :)"



