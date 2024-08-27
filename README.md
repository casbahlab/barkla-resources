# barkla-resources
Resources and material for setting up your Barkla project

## Setup
The first thing to do is to request access to Barkla, by following all the
instructions [at this link](https://www.liverpool.ac.uk/it/advanced-research-computing/access/).
After you are granted access to Barkla, you can connect to infrastructure
via `ssh` (to run commands, create environments, etc.) or via `sftp` (to upload
data to Barkla, or to get data from it). There are plenty of tutorials online
on how to use ssh and sftp.

To connect to Barkla from campus, simply run the command below with your username.
If you are working from home, you need a VPN connection first (more info at
[this link](https://www.liverpool.ac.uk/it/vpn/)).

```bash
ssh <your_uol_username>@barkla.liv.ac.uk
```

What are the main step to start executing code on Barkla?

1. Create a conda environment (or a virtual environment) for your project
2. Activate your environment and install all libraries and sofware there
3. Writing (at least) a configuration file in SLURM to schedule your job.
4. Using `tmux` to leave your job(s) running there while you are away
5. Inspecting the output files

In the following sections, we will go through the main steps.

## Working with Conda

Conda is an open-source package and environment management system. It simplifies the process of installing, running, and updating various software packages and their dependencies. Here's why students should consider using Conda:

Isolation of project environments: Conda allows you to create separate environments for each project, ensuring that different projects with potentially conflicting dependencies don't interfere with each other.
- Easy package management: Conda simplifies the installation of software packages, including handling complex dependencies.
- Cross-platform compatibility: Conda works across various operating systems (Windows, macOS, Linux), making your projects portable.
- Versatility: Conda can manage not just Python packages but also packages from other languages like R, C++, and more.

## Creating and Managing Conda Environments

Let's illustrate how to create a Conda environment, install packages, activate it, and execute code within it. As Barkla already comes with `conda`, the first step is to load the correspoding module by running the command below.

```bash
module add libs/nvidia-cuda/12.4.0/bin
```

Then you can start creating your own environment:

```bash
conda create --name my_project_env python=3.10
```

This command creates a new environment named `my_project_env` with Python version 3.10. After activating your environment, you can then easily install your own packages as follows.

```bash
conda activate my_project_env 
conda install numpy pandas matplotlib
```

This example will activate the environment and install essential packages like NumPy, Pandas, and Matplotlib.  For more sophisticated packages like PyTorch, you might need to install them separately:

```bash
conda install pytorch torchvision torchaudio cpuonly -c pytorch
```

This will install PyTorch with GPU support. A typical workflow is to Activate the environment again (if you've deactivated it) and run your Python script (`my_script.py`) within the environment, ensuring it uses the correct package versions.; and if you need more packages, you can always add them later!

```bash
conda activate my_project_env
python my_script.py
```

By leveraging Conda, users can establish well-organized and reproducible project environments, facilitating efficient development and collaboration. It streamlines package management and ensures compatibility, allowing users to focus on their project goals without getting bogged down by technical complexities.


## Understanding SLURM

### What is SLURM?

SLURM, which stands for Simple Linux Utility for Resource Management, is an open-source workload manager designed to allocate computing resources on clusters or high-performance computing (HPC) systems. It allows users to submit, schedule, and manage jobs efficiently. By prioritizing tasks and distributing resources, SLURM ensures optimal utilisation of the system, enabling researchers, scientists, and engineers to execute computationally demanding tasks effectively.

### SLURM macros

A full working example of a SLURM sccript can be found at `resources/example_script.sh`.
Let's explore the SLURM macros at the top of our example script. These special comments instruct the scheduler about resources, output files, and configurations.

```bash
#SBATCH -D ./
#SBATCH --export=ALL
#SBATCH -J tester
#SBATCH -o tester.%N.%j.out
#SBATCH -e tester.%N.%j.err
#SBATCH -p nodes
#SBATCH -N 1
#SBATCH -n 10
#SBATCH -t 00:05:00
```

`#SBATCH -D ./`: This sets the working directory for your job to the current directory (where the script is located).

`#SBATCH --export=ALL`: This ensures that all environment variables from your current session are passed to the compute nodes where your job will run.

`#SBATCH -J tester`: Assigns the name "tester" to your job. This helps in identification when monitoring or managing jobs.

`#SBATCH -o tester.%N.%j.out`: Defines the name of the standard output file. It will be created in the format "tester.nodename.jobid.out".

`#SBATCH -e tester.%N.%j.err`: Specifies the name for the standard error file, following the format "tester.nodename.jobid.err".

`#SBATCH -p nodes`: Requests that your job be scheduled on the partition named "nodes". Partitions are used to segregate resources for different types of jobs or user groups.

`#SBATCH -N 1`: Asks for 1 node to be allocated for your job.

`#SBATCH -n 10`: Requests 10 tasks (or processes) to be launched for your job.

`#SBATCH -t 00:05:00`: Sets a time limit of 5 minutes for your job. If it exceeds this time, it will be terminated by the scheduler.

These macros offer a powerful way to customise your job submissions and streamline resource management within the SLURM environment. By providing clear instructions to the scheduler, you can enhance efficiency and optimize the execution of your computational workloads.

Please note that this is a basic overview. SLURM offers a wide array of macros for fine-grained control over job parameters and resource allocation. For more advanced use cases, refer to the official SLURM documentation.

### Loading software modules

As part of your SLURM script, you may want to load software modules and libraries
that are already installed and configured on Barkla. This is quite intuitive.
For example, to load anaconda, nvidia-cuda, and cudnn, you simply need to include
the following commands in your script (right after the SLURM macros).

```bash
module purge
module add libs/nvidia-cuda/12.4.0/bin
module add libs/cudnn/8.9.2.26+cuda12
module add apps/anaconda3/2023.03-poetry
```

This will allow you to use conda to activate your environment before you
start your own scripts. If you are working with a deep learning library (e.g.
`torch` or `tensorflow`), you will also need to load cuda and cudnn. Please,
note that, depending on your setup (torch version, etc.), you may need specific
versions of these modules.

