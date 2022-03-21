.. Drug Sniffer documentation master file, created by
   sphinx-quickstart on Fri Feb 18 10:29:57 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Drug Sniffer
============

*Drug Sniffer* is a virtual screening (VS) pipeline capable of screening
billions of molecules using only thousands of CPU hours, using a novel
combination of ligand-based (LBVS) and structure-based (SBVS) methods.

The pipeline requires the user to identify the structure and pocket of the
target protein (stages 1 and 2). These stages are completed manually by the
user.

Then, the pipeline begins by designing multiple de novo ligands for the
identified binding pockets (stage 3). Next, it uses these ligands as seeds to
identify similar compounds from a small-molecule database (stage 4). The
resulting neighbors are then subjected to rigid-body docking (stage 5) and
re-ranked with a new scoring model (stage 6).

Optionally, the pipeline also allows the user to run possible ligands through
`FP-ADMET <https://gitlab.com/vishsoft/fpadmet>`_, an ADMET filter (stage 7).

The *Drug Sniffer* pipeline has been implemented as a `Nextflow
<http://nextflow.io>`_ workflow. Each stage has a corresponding script and
Docker image that are used to execute the computations contained in the stage.

Code can be found on
`GitHub <https://github.com/TravisWheelerLab/drug-sniffer>`_.

See the :ref:`usage` guide for details on how to run *Drug Sniffer*.

.. image:: _static/pipeline.png
  :width: 600
  :alt: Drug Sniffer Pipeline

Table of Contents
=================


.. toctree::
   :maxdepth: 2

   usage
   stages
   parameters


Indices
=======

* :ref:`genindex`
* :ref:`search`

Acknowledgements
================

This research was supported in part by:

* Research Council of Norway (Grant No. 262152)
* National Institutes of Health (NIH), Department of Health and Human Services
  under BCBB Support Services Contract HHSN316201300006W/HHSN27200002 to MSC,
  Inc.
* This research was supported in part by NIH grant R01GM132600 and DOE grant
  DE-SC0021216.

The *Drug Sniffer* software was developed by the `Wheeler Lab
<http://wheelerlab.org>`_ at the University of Montana, along with other
collaborators.
