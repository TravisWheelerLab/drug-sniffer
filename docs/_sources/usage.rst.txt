.. _usage:

Usage
=====

Nextflow Workflow
-----------------

Drug Sniffer is implemented as a `Nextflow <https://nextflow.io>`_ workflow. See
:ref:`parameters` for details on the available workflow parameters.

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

See the Nextflow `documentation
<https://www.nextflow.io/docs/latest/index.html>`_ for information about other
environments, including `SLURM
<https://www.nextflow.io/docs/latest/executor.html#slurm>`_. The configuration
file format is also `described
<https://www.nextflow.io/docs/latest/config.html>`_.

Next, we specify a set of parameters for the workflow run with
``-params-file 3vri_params.yaml``. This tells Nextflow to load workflow
parameters from the specified YAML file. An example file is shown below:

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

The parameters described in this file are explained on the :ref:`parameters`
page. Of interest, however, is the ``${launchDir}`` variable,
which is set to the directory from which the ``nextflow`` command is run
(running a Nextflow workflow is often called "launching" it). There is also a
variable called ``projectDir`` available which is set to the location of the
workflow itself (the ``.nf`` file).

Finally, the Nextflow script is specified. The Drug Sniffer script is defined in
``workflow/workflow.nf``.

Output
------

There are two output files. The first, ``all_errors.txt``, contains errors
produced during the workflow run. The second, ``all_results.txt`` contains the
actual output. The output file is tab-separated and includes the fields listed
below:

1. Pose - the ID of the Autodock Vina pose
2. Chemical name - the name of the chemical from the molecule database
3. Chemical database - the name of the database the chemical can be found in
4. Chemical SMILES string - the raw SMILES string
3. dock2bind score - the score assigned by the dock2bind model
4. Three columns per ADMET check - predicted, confidence, and credibility, see
   the `FPADMET <https://gitlab.com/vishsoft/fpadmet>`_ documentation for more
   details
5. The calculated ``logp`` value

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
