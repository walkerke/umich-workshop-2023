# umich-workshop-2023

Slides and code for Census data workshops given at the University of Michigan in 2023

This repository contains materials for a series of workshops on using Census data in R and Python given for the University of Michigan's Social Science Data Analysis Network in February of 2023.  

Workshop slides are available from the links below:

* February 8, 2023: [Working with the 2021 American Community Survey with R and tidycensus](https://walker-data.com/umich-workshop-2023/acs-2021/#1)

* February 15, 2023: [Mapping and spatial analysis with ACS data in R](https://walker-data.com/umich-workshop-2023/spatial-data/#1)

* February 22, 2023: Working with geographic data and making maps in Python

---

## Instructions for the first two workshops

- Users new to R and RStudio should use the pre-built Posit Cloud environment available at https://posit.cloud/content/5377428.  

- Advanced users familiar with R and RStudio should clone the repository to their computers with the command `git clone https://github.com/walkerke/umich-workshop-2023.git`.  They should then install the following R packages, if not already installed:

```r
pkgs <- c("tidycensus", "tidyverse", "mapview", "plotly", "ggiraph", 
          "survey", "srvyr", "mapedit", "mapboxapi", 
          "leafsync", "spdep", "segregation")

install.packages(pkgs)
```

Experienced users should re-install __tidycensus__ to get the latest updates and ensure that all code used in the workshop will run.  

Other packages used will be picked up as dependencies of these packages on installation. 

A Census API key is recommended to access the Census API.  Participants can sign up for a key at https://api.census.gov/data/key_signup.html (it generally takes just a few minutes). 

---

## Instructions for the third (Python) workshop

Users newer to Python should use the hosted Colab notebooks. Access them from these links:

* [Part 1: An introduction to spatial data in Python](https://colab.research.google.com/drive/1IVQ1phTj2IlgYqIhz41jIepVe49fYnXR?usp=sharing)

* [Part 2: Finding data and making maps in Python](https://colab.research.google.com/drive/1lmXZwTFwSl5yZAfSRiOS8MNRDVz7eeci?usp=sharing)

* [Part 3: Doing GIS and spatial data analysis in Python](https://colab.research.google.com/drive/1DbGEqd0PqVXjQ_BEyooBkDKh5IRE7FeW?usp=sharing)

Advanced users can clone the repository and build a conda environment using the `environment.yml` file in the `python` folder.  Then, they should activate the `ssdan-python` environment.

```bash
conda env create -f environment.yml
conda activate ssdan-python
```

