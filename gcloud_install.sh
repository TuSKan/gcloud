#! /bin/bash

echo
echo Init Config
echo
sudo su
cd $HOME
mkdir install ; cd install

apt-get install -y software-properties-common apt-transport-https lsb-release

echo
echo apt update
echo
add-apt-repository main
add-apt-repository universe
add-apt-repository restricted
add-apt-repository multiverse
apt-get -y update
apt-get -y dist-upgrade
apt-get -y upgrade

echo
echo apt install devlibs
echo
apt-get install -y software-properties-common curl  gcc g++ gfortran make libxml2-dev libgsl-dev libcairo2-dev unixodbc-dev libmariadbclient-dev xfonts-utils libpq-dev libegl1-mesa libegl1-mesa-dev libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgles2-mesa  libllvm5.0 freeglut3-dev mesa-common-dev mesa-utils libssh-dev  libssh2-1-dev libcurl4-openssl-dev libpng-dev libclang-dev  zlib1g-dev psmisc libclang-3.8-dev libclang-common-3.8-dev libclang-dev libclang1-3.8 libgc1c2 libllvm3.8 libobjc-6-dev libobjc4 zip unzip swig git
apt -y --fix-broken install
apt-get -y build-dep build-essential

echo
echo install Intelpython
echo

wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list

apt-get update
apt-get -y install intelpython3
source  /opt/intel/intelpython3/bin/activate

echo Libraries
pip install --upgrade pip
pip install mlflow auto-sklearn tensorflow keras featuretools

echo
echo install Microsoft R
echo
wget https://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb
dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb 

wget https://mran.blob.core.windows.net/install/mro/3.5.1/microsoft-r-open-3.5.1.tar.gz
tar -xf microsoft-r-open-3.5.1.tar.gz
cd microsoft-r-open/
./install.sh -a -s

mkdir -p /usr/lib/R/library
chmod -R u+wx /usr/lib/R/library
mv /opt/microsoft/ropen/3.5.1/lib64/R/library /usr/lib/R
ln -s /usr/lib/R/library /opt/microsoft/ropen/3.5.1/lib64/R/library 

echo Libraries
Rscript -e "install.packages(c('devtools','remotes','farff','BBmisc','checkmate','parallelMap','ParamHelpers','grDevices','methods','ggplot2','ggthemes','magrittr','utils','stats','parallel','data.table','zoo','tictoc','jsonlite','mlr','mlrCPO','mlrMBO','shiny','reticulate','DT','feather', 'fst', 'ggthemes', 'haven', 'pool', 'R.utils', 'readODS', 'readxl', 'rmatio'))'
Rscript -e "remotes::install_github('mlr-org/mlr')"
Rscript -e "remotes::install_github('mlr-org/mlrMBO')"
Rscript -e "remotes::install_github('mlr-org/mlrCPO')"
Rscript -e "remotes::install_github('jakob-r/mlrHyperopt')"
Rscript -e "remotes::install_github('TuSKan/automlr')"
Rscript -e "remotes::install_github('TuSKan/materializer')"
Rscript -e "remotes::install_github('rstudio/forge')"
Rscript -e "devtools::install_github('mlflow/mlflow', subdir = 'mlflow/R/mlflow')"

echo
echo install RStudio
echo
wget https://s3.amazonaws.com/rstudio-ide-build/server/debian9/x86_64/rstudio-server-1.2.1013-amd64.deb
dpkg -i rstudio-server-1.2.1013-amd64.deb

echo
echo install jupyter lab hub
echo
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs

npm install -g configurable-http-proxy

pip install --upgrade notebook
pip install --upgrade ipywidgets
pip install --upgrade jupyter-client
pip install --upgrade jupyterlab
pip install --upgrade jupyterhub
pip install --upgrade sudospawner

curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update && apt-get install yarn
wget https://github.com/yarnpkg/yarn/releases/download/v1.7.0/yarn-1.7.0.js -O /opt/intel/intelpython3/lib/python3.6/site-packages/jupyterlab/staging/yarn.js

jupyter labextension install
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/hub-extension

wget https://gist.githubusercontent.com/lambdalisue/f01c5a65e81100356379/raw/ecf427429f07a6c2d6c5c42198cc58d4e332b425/jupyterhub -O /etc/init.d/jupyterhub
chmod +x /etc/init.d/jupyterhub
mkdir /etc/jupyterhub/

echo
echo Config jupyterhub
echo
/opt/intel/intelpython3/bin/jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py
sh -c "cat <<EOF >> /etc/jupyterhub/jupyterhub_config.py

## Config Added Startup Script
c.JupyterHub.bind_url = 'http://:8888'
c.JupyterHub.spawner_class='sudospawner.SudoSpawner'
c.Spawner.environment = { 'JUPYTER_ENABLE_LAB': 'yes' }
c.Spawner.cmd = ['jupyter labhub']
c.Spawner.default_url = '/lab'
#c.PAMAuthenticator.open_sessions = False
EOF"

sh -c "cat <<EOF > /etc/systemd/system/jupyterhub.service
[Unit]
Description=Jupyterhub
After=syslog.target network.target

[Service]
User=root
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/intel/intelpython3/bin"
ExecStart=/opt/intel/intelpython3/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py

[Install]
WantedBy=multi-user.target
EOF"

systemctl enable jupyterhub
systemctl start jupyterhub
systemctl status jupyterhub

Rscript -e "remotes::install_github('IRkernel/IRkernel')"
Rscript -e "IRkernel::installspec(user = FALSE)"

echo
echo Shiny Server
echo
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb
dpkg -i shiny-server-1.5.9.923-amd64.deb

echo
echo mlflow server
echo
mkdir -p /srv/mlflow/runs
sh -c "cat <<EOF > /srv/mlflow/mlflow-server.sh
PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/intel/intelpython3/bin
source /opt/intel/intelpython3/bin/activate
mlflow server \
    --file-store /srv/mlflow/runs \
    --default-artifact-root gs://mlflow-deploy/ \
    --host 0.0.0.0 \
    --port 5000
EOF"

chmod u+x /srv/mlflow/mlflow-server.sh

sh -c "cat <<EOF > /etc/systemd/system/mlflow.service
[Unit]
Description=MLflow
After=syslog.target network.target

[Service]
User=root
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/intel/intelpython3/bin"
ExecStart=/bin/bash /srv/mlflow/mlflow-server.sh

[Install]
WantedBy=multi-user.target
EOF"

systemctl enable mlflow
systemctl start mlflow
systemctl status mlflow

echo
echo Finish!
echo

/sbin/shutdown -r now