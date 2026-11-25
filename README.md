<h1 align="center">MRtrix2 CSD</h1>

<p align="center">
  Fibre orientation distributions at every even spherical-harmonic order up to a maximum, and the response function, from single-shell DWI with MRtrix 0.2 constrained spherical deconvolution.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.344"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.344-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

## 🧠 At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Fits constrained spherical deconvolution with MRtrix 0.2 at every even lmax up to a maximum and outputs the fibre orientation distributions and response function.**

Builds a brain mask (from the dtiInit brain mask or by thresholding the mean DWI), fits a tensor, derives a single-fibre mask (FA > 0.7) to estimate the response, and runs csdeconv for lmax 2, 4, ... up to max_lmax. Use it to produce MRtrix2 CSD inputs for MRtrix 0.2-based tractography Apps. Not suited to multi-shell multi-tissue CSD.

| | |
|---|---|
| 📥 **Inputs** | `neuro/mask` (optional) · `neuro/dtiinit` |
| 📤 **Outputs** | `neuro/csd` |
| 🐳 **Container** | `brainlife/mrtrix_on_mcr:1.0` |
| ⚙️ **Resources** | 8 CPUs · 1 h walltime |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.344](https://doi.org/10.25663/brainlife.app.344) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `brainmask` | `neuro/mask` | no | The path to the mask datatype containing the brainmask of the DWI |
| `dtiinit` | `neuro/dtiinit` | yes | The path to the DTIINIT datatype |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `csd` | `neuro/csd` | FODs from the CSD model fit using MRtrix2 |

<details>
<summary><b>⚙️ Parameters</b> (1)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `max_lmax` | number |  | maximum spherical harmonic order (i.e. lmax). If blank, will automatically calculate based on number of shells in data. |

</details>

<!-- brainlife-app:end -->

## 🏷️ Versions on brainlife.io

Two Apps are built from the `v1.0` branch of this repository; they differ only in the input they take.

| App | Input | Branch | Run it | Status |
|---|---|---|---|---|
| Mrtrix2 CSD (dtiinit) | `neuro/dtiinit` | [`v1.0`](https://github.com/brainlife/app-mrtrix2-csd/tree/v1.0) | [doi:10.25663/brainlife.app.344](https://doi.org/10.25663/brainlife.app.344) | current |
| Mrtrix2 CSD | `neuro/dwi` | [`v1.0`](https://github.com/brainlife/app-mrtrix2-csd/tree/v1.0) | [doi:10.25663/brainlife.app.255](https://doi.org/10.25663/brainlife.app.255) | current |

## 🚀 Running the App

### ☁️ On brainlife.io

Open the [dtiinit](https://doi.org/10.25663/brainlife.app.344) or [DWI](https://doi.org/10.25663/brainlife.app.255) version, choose the diffusion input (and, optionally, a brain mask) from your project, set `max_lmax` and press **Execute**. The App writes a `neuro/csd` dataset tagged `mrtrix2` to your project, which can guide MRtrix 0.2-based tractography Apps. It is meant for single-shell data and is not suited to multi-shell multi-tissue CSD.

- **`max_lmax`**: the maximum spherical-harmonic order. CSD is fitted at every even order from 2 up to this value. If left blank, it is calculated from the number of non-zero b-values in the dtiInit data.

### 🔬 How it works

1. The DWI (from the dtiInit output or the DWI input) and its gradients are converted to MRtrix 0.2 format.
2. A brain mask is taken from the provided mask (or the dtiInit brain mask), or otherwise built by thresholding and median-filtering the mean DWI.
3. A tensor is fitted (`dwi2tensor`), and a single-fibre mask (FA > 0.7 inside the eroded brain mask) is used to estimate the response function (`estimate_response`).
4. `csdeconv` is run at each even lmax up to `max_lmax`.

### 💻 Locally

You need [Singularity/Apptainer](https://apptainer.org/) and [`jq`](https://jqlang.github.io/jq/). The App runs in the `brainlife/mrtrix_on_mcr:1.0` container.

1. Clone this repository and check out the released version (`git checkout v1.0`).
2. Create `config.json` with the paths to your inputs. With a dtiInit output:

   ```json
   {
       "dtiinit": "testdata/dtiinit",
       "max_lmax": 8
   }
   ```

   or with a DWI:

   ```json
   {
       "dwi": "testdata/dwi/dwi.nii.gz",
       "bvals": "testdata/dwi/dwi.bvals",
       "bvecs": "testdata/dwi/dwi.bvecs",
       "brainmask": "testdata/mask/mask.nii.gz",
       "max_lmax": 8
   }
   ```

3. Run the App:

   ```bash
   ./main
   ```

## 📦 Outputs

```text
csd/
├── lmax2.nii.gz      FODs at lmax 2
├── lmax4.nii.gz      FODs at lmax 4
├── …                 one file per even lmax up to max_lmax
└── response.txt      response function estimated at max_lmax
```

## 🩺 Troubleshooting

- **`csd fit failed`**: the CSD output for `max_lmax` was not written. Check the log, and lower `max_lmax` if the data have too few diffusion directions.
- **Blank `max_lmax` with a DWI input**: the automatic lmax calculation reads the b-values from a dtiInit output, so set `max_lmax` explicitly when you use the DWI version.

## 📚 Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Tournier J-D, Calamante F, Gadian DG, Connelly A. Direct estimation of the fiber orientation density function from diffusion-weighted MRI data using spherical deconvolution. *NeuroImage* 23(3):1176–1185 (2004).
- Tournier J-D, Calamante F, Connelly A. MRtrix: diffusion tractography in crossing fibre regions. *International Journal of Imaging Systems and Technology* (2012). [doi:10.1002/ima.22005](https://doi.org/10.1002/ima.22005)
- Mrtrix2 CSD (dtiinit). brainlife.io App. [doi:10.25663/brainlife.app.344](https://doi.org/10.25663/brainlife.app.344)
- Tournier et al. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage* 202:116137 (2019). [doi:10.1016/j.neuroimage.2019.116137](https://doi.org/10.1016/j.neuroimage.2019.116137)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## 👥 Authors

- Brad Caron
- Brent McPherson

**Contributors:** Soichi Hayashi

## 💰 Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## ⚖️ License

MIT (see the [`LICENSE`](https://github.com/brainlife/app-mrtrix2-csd/blob/v1.0/LICENSE) file on the `v1.0` branch).
