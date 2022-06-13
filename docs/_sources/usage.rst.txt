.. _usage:

Usage
=====

Prerequisites
-------------

*Drug Sniffer* is implemented as a `Nextflow <https://nextflow.io>`_ workflow.
Users will need to install Nextflow before they can use *Drug Sniffer*, it is
generally quite easy to install, see the website for details.

Note that when Nextflow is installed using the default method, a file called
``nextflow`` is created. This can be moved to a location on the user's ``PATH``
or it can be invoked like ``./nextflow``, per standard Unix practices.

`Docker <https://www.docker.com>`_ also must be installed in the execution
environment and configured so that the user launching the Nextflow workflow has
permission to run Docker containers. In the future, we intend to support
`Singularity <https://sylabs.io/singularity>`_ containers as well since this
container runtime is more commonly available in HPC environments.

Containers
----------

The first step is to build the Docker images. This can be done by running
the ``build-images.sh`` script in the ``tool/`` directory.

::

  ./tool/build-images.sh

This will build the necessary Docker images. If the workflow is to be run on a
cluster or cloud environment then it may be necessary to push the images to a
registry. In this case, set the ``IMAGE_NAMESPACE`` environment variable to
a valid registry and namespace when running the script above.

::

  IMAGE_NAMESPACE=fancyregistry.io/mylab ./tool/build-images.sh

If the ``IMAGE_PUSH`` environment variable is set to anything other than ``0``
(the default), the images will also be pushed to the specified registry,
which defaults to ``docker.io`` is otherwise unspecified.

::

  IMAGE_NAMESPACE=mylab IMAGE_PUSH=1 ./tool/build-images.sh

Running
-------

The simplest way to learn how to use Drug Sniffer is to experiment with the
examples (see below for more information). These may be found in the
``examples/`` directory within the project repository. First, clone the
repository (`<https://github.com/TravisWheelerLab/drug-sniffer>`_). Then,
from the project root directory, you can run one of the examples with the
command below.

::

  nextflow run -profile local -params-file examples/3vri_params.yaml .

There are three things going on here. First, we select the environment the
workflow will run in with ``-profile local``. The available environments are
described in ``nextflow.config`` in the same directory. An example is shown
below:

::

  profiles {
    local {
        process.executor = 'local'
        docker.enabled = true
    }

    aws_batch {
        process.executor = 'awsbatch'
        process.queue = 'drug-sniffer-queue'
        aws.region = 'us-east-1'
    }
  }

The config above describes two environments. The first, ``local``, which runs
the workflow on the local machine, with Docker enabled (Drug Sniffer requires
Docker or another container runtime). The second is ``aws_batch``, which will
run the workflow in the AWS cloud using the Batch batch processing service,
which would need to have been configured with a queue called
``drug-sniffer-queue``.

See the Nextflow `documentation
<https://www.nextflow.io/docs/latest/index.html>`_ for information about other
environments, including `SLURM
<https://www.nextflow.io/docs/latest/executor.html#slurm>`_. The configuration
file format is also `described
<https://www.nextflow.io/docs/latest/config.html>`_.

Next, we specify a set of parameters for the workflow run with
``-params-file examples/3vri_params.yaml``. This tells Nextflow to load
workflow parameters from the specified YAML file. An example file is shown
below:

See :ref:`parameters` for details on the available workflow parameters.

::

  molecule_db: '${projectDir}/../examples/small-db'
  tanimoto_cutoff: 0.5

  receptor_pdb: '${projectDir}/../examples/3vri_aligned.pdb'

  receptor_center_x: 14.641000
  receptor_center_y: -11.026000
  receptor_center_z: 43.231998

  receptor_size_x: 10.0
  receptor_size_y: 10.0
  receptor_size_z: 10.0

  admet_checks: '1 2 3'

  output_dir: '${launchDir}/drug-sniffer-output'

The parameters described in this file are explained on the :ref:`parameters`
page. Of interest, however, is the ``${launchDir}`` variable,
which is set to the directory from which the ``nextflow`` command is run
(running a Nextflow workflow is often called "launching" it). There is also a
variable called ``projectDir`` available which is set to the location of the
workflow itself (the ``.nf`` file).

Finally, we tell Nextflow to run the workflow configured for the current
directory (using ``.``). It is also possible to run the workflow without
cloning the Git repository by referencing the repo on the command line:

::

  nextflow run -profile local -params-file my-params.yaml \
    -r main TravisWheelerLab/drug-sniffer

The ``-r`` option tells Nextflow which branch to use. In this case, our primary
branch is called "main", so that's usually the one you want to execute.

We also suggest using the ``-with-report`` option to the Nextflow "run" command
as it produces a useful report after the workflow has finished. See the `example
<_static/report.html>`_ report for details.

Output
------

There are two output files. The first, ``all_errors.txt``, contains errors
produced during the workflow run. The second, ``all_results.txt`` contains the
actual output. The output file is tab-separated and includes the fields listed
below:

1. Pose - the ID of the Autodock Vina pose
2. Chemical name - the name of the chemical from the molecule database
3. Chemical database - the name of the database that contains the chemical
4. Chemical SMILES string - the raw SMILES string
5. dock2bind score - the score assigned by the dock2bind model
6. Three columns per ADMET check - predicted, confidence, and credibility, see
   the `FPADMET <https://gitlab.com/vishsoft/fpadmet>`_ documentation for more
   details
7. The calculated ``logp`` value

Examples
--------

There are two examples, both found in the ``examples/`` directory within the
repository: ``3vri`` and ``5l2s``. The first, when run, will test a pre-computed
set of ligands, effectively skipping Stage 3 of the pipeline and going right to
Stage 4. This has two benefits. First, Autogrow4 takes a long time to run, so if
the goal is to simply see the pipeline in action, or verify some change, the
``3vri`` example is the way to go. Second, some users may want to create ligands
to test using some other method, and the ``3vri`` example serves to demonstrate
how to do this. The ``5l2s`` example runs the entire pipeline.

.. _molecule-db:

Molecule Database
-----------------

Drug Sniffer requires a database of potential molecules in order to function. We
provide a large, curated database for use by the public. The database is an
aggregation of a number of existing databases intended for drug research, and
each molecule includes a reference back to its original source for convenience.

The database is about 141GB compressed, so it requires a large filesystem.
Further, when running Drug Sniffer on a cluster, we recommend that you make the
database accessible through NFS or some similar means to avoid downloading it on
to each node.

Once extracted, you can point Drug Sniffer at the location using the
:ref:`molecule_db-parameter` parameter.

The full database is available for download at
`<https://data.drugsniffer.org/molecules.zip>`_.
