# Notes on GCP

## Logistics

- Home page: <https://cloud.google.com/>
- Console page: <https://console.cloud.google.com/>
- Google cloud utilities: <https://cloud.google.com/sdk/>
- Demos: <http://googlecloudplatform.github.io/>
- Link for coupons: <http://goo.gl/gcpedu/P4Acj1>

## Step 0: Enable billing

Billing is associated with projects.  You need to create a new project
and attach a billing account to it.  I created one called CUSSW and
associated the CUSSW billing account to it.  This takes a moment to
set up.  Once you have the account enabled, go to that page on the
console

## Step 1: Setting up a simple VM

We can walk through the tutorial under "Try Compute Engine."  Note that
it may take a moment to get ready.  We will follow the tutorial, setting
up a new 10 GB persistent disk with one vCPU.  This can also be done
from the command line:

    gcloud auth login
    gcloud config set project cussw-148113

We will start by running a simple web server.  You can see what the
external IP is pretty easily by looking at the instance.

Shutdown.

## Step 2: Installing something interesting

Let's create a new instance and SSH into it.  Note that we automatically have
root access when we use the cloud SSH.  This time, I am going to create
something using Ubuntu.

I prefer Anaconda to the built-in Python distribution, so I am going to start
by installing Anaconda.  I ssh into my instance and type:

    wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
    bash Anaconda3-4.2.0-Linux-x86_64.sh

I will use the default location.  It takes a moment to install all the
dependencies.  Note that MKL is included!  I let it update my bashrc, and
then source the bashrc file to make it immediately available.  Then let's
make sure that I have Jupyter installed:

    conda install ipython-notebook

I am also going to install Julia:

    sudo add-apt-repository ppa:staticfloat/juliareleases
    sudo add-apt-repository ppa:staticfloat/julia-deps
    sudo apt-get update
    sudo apt-get install julia

You may notice that the installations go blazingly fast -- this is an
advantage of running inside of Google's cloud.  They apparently have
local mirrors of lots of things (and really high bandwidth if they do
not have a local mirror).  First, we need to make sure that ZeroMQ is
installed:

    sudo apt-get install libzmq3-dev

Let's make sure that IJulia and PyPlot are also installed; start Julia and run

    Pkg.update()
    Pkg.add("IJulia")
    Pkg.add("PyPlot")

## Step 3: Start a Jupyter notebook

From a terminal, we are going to start an SSH tunnel:

    gcloud compute ssh instance-3 --zone=us-east1-c -- \
      -L 8888:localhost:8888

If this is your first time using gcloud compute ssh, you will need to
set up a key (straightforward).  This ssh command opens a terminal on
the remote host, from which you can type

    jupyter notebook

Now in your web browser, go to <http://localhost:8888>.  We will create
a new Julia notebook and do some random plot:

    using PyPlot
    x = linspace(0,2*pi,1000); y = sin(3*x + 4*cos(2*x))
    plot(x, y, color="red", linewidth=2.0, linestyle="--")

The display is on your local host, but the actual computations are being
done on the remote machine.

If I wanted to, I could also create a Jupyter notebook on a Cloud Dataproc
cluster; see the [tutorial](https://cloud.google.com/dataproc/docs/tutorials/jupyter-notebook).
This tutorial uses a more complicated proxy setup via SOCKS5.

## Step 4: Client-server computing

We are going to clone our prior instance (we will do it from the console).
I'm going to take a snapshot of the source disk from the previous instance.
To do this, I click on the instance, scroll down to the drive, and click
the "create snapshot" button.  It takes just a little bit.  Now when I go
to create a new instance, I can select the snapshot as my boot disk.

I am going to start both `instance-3` and `instance-4` simultaneously.
I will log into the former instance from my machine as

    gcloud compute ssh instance-3 --zone=us-east1-c -- -L 8888:localhost:8888

I could start up a new Jupyter notebook, but first I will check my ssh
keys by logging into `instance-4` from `instance-3`.

    ssh instance-4

This checks to make sure I want to continue, but nothing else.  I exit out,
as I just wanted to make sure the key setup was correct.  Now let me start
the Jupyter notebook:

    jupyter notebook

and in the notebook, I will run

    addprocs(["instance-4"])

We could also have specified the machines with a machine file.  That is,
we would write a file `machines.txt` containing something like

    localhost
    instance-4

I think?  Except that what is actually happening is that
