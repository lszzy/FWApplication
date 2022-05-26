#! /bin/bash

cd FWApplication/Classes/include
rm -rf FWApplication
mkdir FWApplication
cd FWApplication

ln -s ../../FWApplication/Module/*/*.h ./
ln -s ../../FWApplication/Plugin/*/*.h ./
ln -s ../../FWApplication/Service/*/*.h ./
ln -s ../../FWApplication/Toolkit/*/*.h ./

