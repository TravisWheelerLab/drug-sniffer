Usage
=====

Nextflow Workflow
-----------------

Drug Sniffer is implemented as a `Nextflow <https://nextflow.io>`_ workflow. See
:ref:`Parameters <parameters>` for details on the available workflow parameters.

The simplest way to learn how to use Drug Sniffer is to experiment with the
examples (see below for more information). These may be found in the
``examples/`` directory within the project repository. From this directory, you
can run one of the examples with the command below.

::

  nextflow run \
    -profile local \
    -params-file 3vri_params.yaml \
    ../workflow/workflow.nf

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

Second, we specify a set of parameters for the workflow run with
``-params-file 3vri_params.yaml``. This tells Nextflow to load workflow parameters
from the specified YAML file. An example file is shown below:

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

The parameters described in this file are explained on the :ref:`Parameters
<parameters>` page. Of interest, however, if the ``${projectDir}`` variable,
which is set to the location of the workflow script (the ``.nf`` file) at
runtime. There is also a variable called ``launchDir`` available which is set to
the directory from which the Nextflow command line tool is invoked.

Finally, the Nextflow script is specified. The Drug Sniffer script is defined in
``workflow/workflow.nf``.

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

Docker Images
-------------

Each stage in the Drug Sniffer pipeline has its own Docker image. The images can
be built all at once with the `build-images.sh` script found in the `tool/`
directory, which can be run from the repository root. This script accepts three
parameters as environment variables, listed below. These allow the images to be
built and pushed to registries other than the default locations.

* :code:`IMAGE_REGISTRY` - the registry that will host the image, this doesn't
  matter if the image will only be used locally
* :code:`IMAGE_NAMESPACE` - the owner of the image, this is usually a project or
  organization name and, again, doesn't matter for images that will never be
  pushed to a registry
* :code:`IMAGE_VERSION` - the version identifier to be applied to the image

All of the variables above have usable defaults.
