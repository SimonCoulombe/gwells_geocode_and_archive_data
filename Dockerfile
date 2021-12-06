FROM rocker/geospatial:4.1.2


LABEL maintainer="simoncoulombe@protonmail.com"
LABEL description="Base image with RStudio and Conda"


ENV miniconda3_version="py39_4.9.2"
ENV miniconda_bin_dir="/opt/miniconda/bin"
ENV PATH="${PATH}:${miniconda_bin_dir}"


# Safer bash scripts with 'set -euxo pipefail'
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update -yqq
RUN apt-get install -yqq nano

RUN apt-get update -qq -y \
    && apt-get install --no-install-recommends -qq -y \
        bash-completion \
        curl \
        gosu \
        libxml2-dev \
        zlib1g-dev \
        # Fix https://github.com/tschaffter/rstudio/issues/11 (1/2)
        libxtst6 \
        libxt6 \
        # Lato font is required by the R library `sagethemes`
        fonts-lato \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    # Fix https://github.com/tschaffter/rstudio/issues/11 (2/2)
    && ln -s /usr/local/lib/R/lib/libR.so /lib/x86_64-linux-gnu/libR.so 
RUN  curl -fsSLO https://repo.anaconda.com/miniconda/Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
    && bash Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
        -b \
        -p /opt/miniconda \
    && rm -f Miniconda3-${miniconda3_version}-Linux-x86_64.sh \
    && useradd -u 1500 -s /bin/bash miniconda \
    && chown -R miniconda:miniconda /opt/miniconda \
    && chmod -R go-w /opt/miniconda \
    && conda --version

#  clone github
RUN git clone https://github.com/simoncoulombe/GWELLS_LocationQA.git


# creat environmente defined in github
RUN conda env create -f /GWELLS_LocationQA/environment.yml

# install aws cli to download tif from s3
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
RUN unzip /tmp/awscliv2.zip -d /tmp
RUN sudo /tmp/aws/install
RUN rm -rf /tmp/*

# download 
RUN ./GWELLS_LocationQA/get_esa_worldcover_bc.sh 

# RUN echo "conda activate gwell_locationqa" >> ~/.bashrc

#COPY prout.sh /tmp/prout.sh

# install R libraries
RUN install2.r --error --skipinstalled --ncpus -1 \
    janitor \
    sessioninfo \
    kableExtra \
    mapview
