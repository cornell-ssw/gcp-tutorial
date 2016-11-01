# Make sure all packages are up-to-date
sudo apt-get update -y

# Set up git
sudo apt-get install -y git

# Set up essentials and some compilers
sudo apt-get install -y build-essential
sudo apt-get install -y gcc gfortran

# ZeroMQ for Jupyter
sudo apt-get install -y libzmq3-dev

# Turn off strict host key checks and create a shared key (for cloned images)
echo "StrictHostKeyChecking no" | sudo tee --append /etc/ssh/ssh_config
echo "HashKnownHosts No" >> $HOME/.ssh/config
ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -N '' -C "MPI Keys"
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Install OpenMPI
sudo apt-get install -y libopenmpi-dev openmpi-bin

# Install Anaconda Python
wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
bash Anaconda3-4.2.0-Linux-x86_64.sh
export PATH=$HOME/anaconda3/bin:$PATH
conda install -y jupyter
conda install -y ipython-notebook

# Install Julia official build
wget https://julialang.s3.amazonaws.com/bin/linux/x64/0.5/julia-0.5.0-linux-x86_64.tar.gz
tar -xzf julia-0.5.0-linux-x86_64.tar.gz -C $HOME

# Add Julia to the path (and the default path)
JULIA=`ls $HOME | grep julia-`
echo $JULIA
export PATH=$HOME/$JULIA/bin:$PATH
echo "export PATH=\"$HOME/$JULIA/bin:\$PATH\"" >> ~/.bashrc

# Set up some Julia packages
julia setup.jl

