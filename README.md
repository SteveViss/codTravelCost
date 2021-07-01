# Project structure

- `distMatrix.R`: Main script
- `ne_10m_land`: Inland polygons (from www.naturalearthdata.com)
- `renv.lock`: All R dependancies

# Method

The _Gadus morhua_ travel distances among sampling stations were computed using R (4.1.0) and the gdistance package (Van Etten 2017, v1.3-6). In order for the species to avoid inland areas and specific unsuitable habitat (such as Bras d'or Lake or and the Canso Canal), we articialy increase the cost of the transition matrix of those areas. The least-cost travel distances among stations were then found using a random walks algorithm (gdistance, Van Etten 2017, v1.3-6). 

# Reference

Van Etten, J. (2017). R package gdistance: Distances and routes on geographical grids. Journal of
Statistical Software, 76(1), 1–21. https://doi.org/10.18637/jss.v076.i13

@Article{,
    author = {Jacob {van Etten}},
    title = {R Package gdistance: Distances and Routes on Geographical Grids},
    doi = {10.18637/jss.v076.i13},
    year = {2017},
    month = {feb},
    publisher = {Foundation for Open Access Statistics},
    volume = {76},
    number = {13},
    pages = {21},
    journal = {Journal of Statistical Software},
}