#! /bin/bash

cd FWApplication/Classes/include
rm -rf FWApplication
mkdir FWApplication
cd FWApplication

ln -s ../../FWApplication/App/*.h ./
ln -s ../../FWApplication/App/*/*.h ./
ln -s ../../FWApplication/App/*/*/*.h ./
ln -s ../../FWApplication/Controller/*.h ./
ln -s ../../FWApplication/Model/*.h ./
ln -s ../../FWApplication/Model/*/*.h ./
ln -s ../../FWApplication/Service/*/*.h ./
ln -s ../../FWApplication/Service/*/*/*.h ./
ln -s ../../FWApplication/View/*.h ./
ln -s ../../FWApplication/View/*/*.h ./
