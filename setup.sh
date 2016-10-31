sudo apt-get install build-essential
wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
bash Anaconda3-4.2.0-Linux-x86_64.sh
sudo add-apt-repository ppa:staticfloat/juliareleases
sudo add-apt-repository ppa:staticfloat/julia-deps
sudo apt-get update
sudo apt-get install julia
sudo apt-get install libzmq3-dev

. $HOME/.bashrc
conda install jupyter
conda install ipython-notebook
julia setup.jl
