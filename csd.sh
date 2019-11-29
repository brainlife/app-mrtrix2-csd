#!/bin/bash

## Single-shell csd tracking over ensemble of lmax's
## modified by Brad Caron for Optic Radiation - Eccentricity project - 20191129

## Ilaria Sani - 20180313
## Human Engogenous Attention Network
## (modified after Ilaria Sani - 20170117 - NHP Endogenous Attention Network)
## (modified after Brent McPherson)
## (modified by Brad Caron for Optic Radiation - Eccentricity project - 20191122)

## MRTRIX PRE-PROCESSING (no need for WM mask for humans)
## This script process DTI data with MRTRIX, i.e. prepares the data for tracking
## it also creates a WM mask
## 
## NEEDS:
## 1. $dwi.mif
## 2. grads.b 
## 3. mask.mif 

#make the script to fail if any of the command fails.
#set -e

#show commands executed (mainly for debugging)
#set -x

########### DEFINE PATHS #####################
export PATH=$PATH:/usr/lib/mrtrix/bin

BGRAD="grad.b"
input_nii_gz=`jq -r '.dwi' config.json`
BVALS=`jq -r '.bvals' config.json`
BVECS=`jq -r '.bvecs' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
brainmask=`jq -r '.brainmask' config.json`
MAXLMAX=`jq -r '.max_lmax' config.json`
WMMK=wm_mask.mif

mkdir csd

if [[ ! ${dtiinit} == "null" ]]; then
	dtiinit=`jq -r '.dtiinit' config.json`
	input_nii_gz=$dtiinit/`jq -r '.files.alignedDwRaw' $dtiinit/dt6.json`
	BVALS=$dtiinit/`jq -r '.files.alignedDwBvals' $dtiinit/dt6.json`
	BVECS=$dtiinit/`jq -r '.files.alignedDwBvecs' $dtiinit/dt6.json`
	brainmask=$dtiinit/`jq -r '.files.brainMask' $dtiinit/dt6.json`
fi

#generate grad.b from bvecs/bvals
#load bvals/bvecs
bvals=$(cat $BVALS)
bvecs_x=$(cat $BVECS | head -1)
bvecs_y=$(cat $BVECS | head -2 | tail -1)
bvecs_z=$(cat $BVECS | tail -1)
#convert strings to array of numbers
bvecs_x=($bvecs_x)
bvecs_y=($bvecs_y)
bvecs_z=($bvecs_z)
#output grad.b
i=0
true > grad.b
for bval in $bvals; do
    echo ${bvecs_x[$i]} ${bvecs_y[$i]} ${bvecs_z[$i]} $bval >> grad.b
    i=$((i+1))
done

#if max_lmax is empty, auto calculate
if [[ $MAXLMAX == "null" || -z $MAXLMAX ]]; then
    echo "max_lmax is empty... determining which lmax to use from .bvals"
    MAXLMAX=`./calculatelmax.py`
fi

if [ ! -f dwi.mif ]; then
    mrconvert $input_nii_gz dwi.mif
fi

########### CREATE FILES FOR CSD ######
## create a t2-mask from b0
if [[ ${brainmask} == 'null' ]]; then
	if [ -f mask.mif ]; then
		echo "t2-mask from b0 already exists...skipping"
	else
		time average dwi.mif -axis 3 - | threshold - - | median3D - - | median3D - mask.mif
		ret=$?
		if [ ! $ret -eq 0 ]; then
			exit $ret
		fi
	fi
else
	if [ ! -f mask.mif ]; then
		mrconvert ${brainmask} mask.mif
	fi
	ret=$?
	if [ ! $ret -eq 0 ]; then
		exit $ret
	fi
fi

## fit diffusion model
if [ -f dt.mif ]; then
	echo "diffusion tensor already exists...skipping"
else
	time dwi2tensor dwi.mif -grad $BGRAD dt.mif
	ret=$?
	if [ ! $ret -eq 0 ]; then
		exit $ret
	fi
fi

## create FA image
if [ -f fa.mif ]; then
	echo "FA image already exists...skipping"
else
	time tensor2FA dt.mif - | mrmult - mask.mif fa.mif
	ret=$?
	if [ ! $ret -eq 0 ]; then
		exit $ret
	fi
fi

## create rgb eingenvectors
if [ -f ev.mif ]; then
	echo "RGB eigenvectors already exists...skipping"
else
	time tensor2vector dt.mif - | mrmult - mask.mif ev.mif
	if [ ! $ret -eq 0 ]; then
		exit $ret
	fi
fi

## create single fiber mask
if [ -f sf.mif ]; then
	echo "Single fiber mask already exists...skipping"
else
	time erode mask.mif -npass 3 - | mrmult fa.mif - - | threshold - -abs 0.7 sf.mif
	if [ ! $ret -eq 0 ]; then
		exit $ret
	fi
fi

for (( i_lmax=2; i_lmax<=$MAXLMAX; i_lmax+=2 )); do
	lmaxvar=$(eval "echo \$lmax${i_lmax}")
	## create response numbers for CSD fit
    	time estimate_response -quiet dwi.mif sf.mif -grad $BGRAD -lmax $i_lmax response${i_lmax}.txt
	
	lmaxout=csd${i_lmax}.mif
        time csdeconv -quiet dwi.mif -grad $BGRAD response${i_lmax}.txt -lmax $i_lmax -mask mask.mif $lmaxout
	
	mrconvert $lmaxout ./csd/lmax${i_lmax}.nii.gz
	ret=$?
    	if [ ! $ret -eq 0 ]; then
		exit $ret
    	fi
done

cp ./response${MAXLMAX}.txt ./csd/response.txt

################# CLEANUP #######################################
if [ -f ./csd/lmax${MAXLMAX}.nii.gz ]; then
    rm -rf *.mif*
    rm -rf grad.b
    rm -rf *response*.txt
    rm -rf *.nii.gz #this removes aparc+aseg.nii.gz and other .nii.gz needed later
    exit 0;
else
    echo "csd fit failed"
    exit 1;
fi
