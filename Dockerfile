FROM rocker/tidyverse:4.0.4
# ubuntu and r package install command
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    byobu \
    graphviz \
    less \
    libgdal26 \
    libproj15 \
    libudunits2-0 \
    libxml2-dev \
    zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && install2.r --error \
    caTools \
    evir \
    knitr \
    poweRlaw \
    rprojroot \
    sf \
    sp \
    sweep \
    xts 
#RUN r -e "devtools::install_github('paul-buerkner/brms',dependencies = TRUE)" 
RUN r -e "install.packages('brms', repos = c('https://mc-stan.org/r-packages/', getOption('repos')))"
#RUN r -e "install.packages('cmdstanr', repos = c('https://mc-stan.org/r-packages/', getOption('repos')))"
#RUN r -e "cmdstanr::install_cmdstan(cores = 10,overwrite=TRUE)"
  


