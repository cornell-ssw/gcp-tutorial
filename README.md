# Notes on GCP

## Logistics

- Home page: <https://cloud.google.com/>
- Console page: <https://console.cloud.google.com/>
- Google cloud utilities: <https://cloud.google.com/sdk/>
- Demos: <http://googlecloudplatform.github.io/>
- Link for coupons: <http://goo.gl/gcpedu/P4Acj1>

## Step 0: Enable billing

Billing is associated with projects.  You need to create a new project
and [attach a billing account to it][gcp-billing]; you can do this by
clicking the hamburger menu in the upper left corner and going to the
"billing" entry.  I created a project called CUSSW and
associated the CUSSW billing account to it.  This takes a moment to
set up.  Once you have the account enabled, go to that page on the
console.

[gcp-billing]: https://support.google.com/cloud/answer/6288653?hl=en

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
something using Debian.  I will use the default settings, except that I
would like to enable the compute API at least at the "read-only" level
so that any one of the machines can list all the active instances in the
project.

The `setup.sh` script in the repository sets up an instance that is
ready for use in a cluster with Python, Julia, or MPI.  The setup script
does two things: it installs a bunch of software, and it sets the SSH
settings to be a little more friendly to us.  In particular, we

 - Turn off strict host key checking, so that we are not prompted to
   accept a key the first time we log into any particular node.
 - Create a new `id_rsa.pub` key and install it in the list of
   authorized keys.

The second step may be somewhat fruitless, since GCP behind the scenes
does some black magic to manage SSH keys for us.  Nonetheless, I had
trouble getting SSH between instances to work consistently without doing
something like this.

To do the installation, we run

    sudo apt-get install -y git
    git clone https://github.com/cornell-ssw/gcp-tutorial.git
    cd gcp-tutorial
    ./setup.sh

Agree to things as prompted, and at the end, you should have a
reasonable setup!

## Step 3: Start a Jupyter notebook

So far, we have seen how to log into an instance with SSH, but we would
like to interact with our remote machine in other ways as well; for
example, we might like to display a web page that is rendered on the
remote machine.  One technique for doing this is to set up an
*SSH tunnel* that connects a port on our local machine to a port on
some Google Compute Engine instance.

From a terminal, we can start an SSH tunnel like this:

    gcloud compute ssh david_bindel@instance-1 --zone=us-east1-c -- \
      -L 8888:localhost:8888

where you will, of course, want to substitute your own user ID and
instance name.  If this is your first time using gcloud compute ssh,
you will need to set up a key when prompted.  This ssh command connects
port 8888 on my local host to port 8888 on the remote machine.
It also opens a terminal on the remote host, from which you can type

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

Now, I would like to show off how to use these to instances as a tiny
Julia compute cluster.  I will log into one of the machines with the
web SSH, and from the terminal type

    gcp-tutorial/mkhostfile.sh

This should create a file in the home directory called `machines.txt`
that lists the name of all the instances currently running in the
project.  We can run workers on all these machines by typing

    julia --machinefile machines.txt

Now from the Julia prompt, we see where things are running via the loop

    @parallel for i = 1:10
        run(`hostname`)
    end

This should print out the name of the instance where each iteration
of the for loop is run.

## Onward!

Some of the setup in this tutorial was taken from
a [related tutorial on GitHub][mpi-cluster].  The nice thing about
that tutorial, which we have not discussed here, is that it describes
how to automate the whole process of spinning up a small cluster.

[mpi-cluster]: https://github.com/NAThompson/mpi_clustering
