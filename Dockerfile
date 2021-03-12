FROM kaybenleroll/r_baseimage:base202012
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

