[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.255-blue.svg)](https://doi.org/10.25663/brainlife.app.255)

# Mrtrix2 CSD 

This app will will fit the constrained spherical deconvolution model using MrTrix0.2. This app takes in a DWI datatype as input and outputs csd's of various spherical harmonic orders (i.e. lmax). The output of this can be used to guide tractography applications. 

### Authors 

- Brad Caron (bacaron@iu.edu)
- Brent McPherson (bcmcpher@iu.edu) 

### Contributors 

- Soichi Hayashi (hayashis@iu.edu) 

### Funding 

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations 

Please cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community. 

1. Fibre-tracking was performed using the MRtrix package (J-D Tournier, Brain Research Institute, Melbourne, Australia, http://www.brain.org.au/software/) (Tournier et al. 2012)
2. Tournier JD, Calamante F, Gadian DG, Connelly A Direct estimation of the fiber orientation density function from diffusion-weighted MRI data using spherical deconvolution Neuroimage 2004; 23 (3): 1176-1185
3. Tournier JD, Calamante F, Connelly A MRtrix: diffusion tractography in crossing fibre regions International Journal of Imaging Systems and Technology 2012; in press, DOI: 10.1002/ima.22005 

## Running the App 

### On Brainlife.io 

You can submit this App online at [https://doi.org/10.25663/brainlife.app.255](https://doi.org/10.25663/brainlife.app.255) via the 'Execute' tab. 

### Running Locally (on your machine) 

1. git clone this repo 

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files. 

```json 
{
   "dwi":    "testdata/dwi/dwi.nii.gz",
    "bvals":    "testdata/dwi/dwi.bvals",
    "bvecs":    "tesdata/dwi/dwi.bvecs",
    "mask":    "testdata/mask/mask.nii.gz/",
    "max_lmax":    8} 
``` 

### Sample Datasets 

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli). 

```
npm install -g brainlife 
bl login 
mkdir input 
bl dataset download 
``` 

3. Launch the App by executing 'main' 

```bash 
./main 
``` 

## Output 

The main output of this App is contains all the requested FOD images (example: lmax2.nii.gz,lmax4.nii.gz,response.txt). 

#### Product.json 

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies 

This App requires the following libraries when run locally. 

- MrTrix0.2: 
 jsonlab: 
- singularity: 
- FSL: 