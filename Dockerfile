# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


FROM debian:9

## (Based on https://github.com/rocker-org/rocker/blob/master/r-base/Dockerfile)
## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (e.g. for linked volumes to work properly).
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& apt-get update && apt-get install -y locales \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		# MRO dependencies that don't sort themselves out on their own:
		less \
		libgomp1 \
		libpango-1.0-0 \
		libxt6 \
		libsm6 \
    wget gcc g++ gfortran make cmake libxml2-dev libgsl-dev unixodbc-dev xfonts-utils libpq-dev libcurl4-openssl-dev zlib1g-dev libssl-dev libssh2-1-dev lsb-release gnupg2 \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -LO  -# http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
      && dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb

# Use major and minor vars to re-use them in non-interactive installation script
ENV MRO_VERSION_MAJOR 3
ENV MRO_VERSION_MINOR 5
ENV MRO_VERSION_BUGFIX 0
ENV MRO_VERSION $MRO_VERSION_MAJOR.$MRO_VERSION_MINOR.$MRO_VERSION_BUGFIX

WORKDIR /home/docker

## Donwload and install MRO & MKL, see https://mran.microsoft.com/download https://mran.blob.core.windows.net/install/mro/3.5.0/microsoft-r-open-3.5.0.tar.gz
RUN curl -LO -# https://mran.blob.core.windows.net/install/mro/$MRO_VERSION/microsoft-r-open-$MRO_VERSION.tar.gz \
	&& tar -xzf microsoft-r-open-$MRO_VERSION.tar.gz
WORKDIR /home/docker/microsoft-r-open
RUN  ./install.sh -a -u

# Clean up downloaded files
WORKDIR /home/docker
RUN rm microsoft-r-open-*.tar.gz \
	&& rm -r microsoft-r-open

# Installs pytorch and torchvision.
RUN Rscript -e "install.packages(c('devtools','farff','BBmisc','checkmate','parallelMap','ParamHelpers','grDevices','methods','ggplot2','magrittr','utils','stats','parallel','data.table','zoo','tictoc','jsonlite','mlr','mlrCPO','mlrMBO'))"

RUN Rscript -e "devtools::install_github('mlr-org/mlr')"
RUN Rscript -e "devtools::install_github('mlr-org/mlrMBO')"
RUN Rscript -e "devtools::install_github('mlr-org/mlrCPO')"
RUN Rscript -e "devtools::install_github('jakob-r/mlrHyperopt')"
RUN Rscript -e "devtools::install_github('TuSKan/automlr')"

RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y

# Copies the trainer code
RUN mkdir /home/docker/train
COPY train/train.R /home/docker/train/train.R
COPY train/parConfigList.R /home/docker/train/parConfigList.R

# Add image metadata
LABEL org.label-schema.license="https://mran.microsoft.com/faq/#licensing" \
    org.label-schema.vendor="Microsoft Corporation, Dockerfile provided by Daniel Nüst" \
	org.label-schema.name="Microsoft R Open" \
	org.label-schema.description="Docker images of Microsoft R Open (MRO) with the Intel® Math Kernel Libraries (MKL)." \
	org.label-schema.vcs-url=$VCS_URL \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.schema-version="rc1" \
	maintainer="Daniel Nüst <daniel.nuest@uni-muenster.de>"


# Setups the entry point to invoke the trainer.
ENTRYPOINT ["Rscript", "train/train.R"]

