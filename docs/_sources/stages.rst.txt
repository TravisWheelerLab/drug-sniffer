Stages
======

The `workflow/` directory contains everything necessary to run the Drug Sniffer
pipeline conveniently on a variety of computing platforms. The individual
components of the pipeline (stages) are described below.

Each stage includes a Docker image (`Dockerfile`) along with dependencies and
scripts. To build the image for a given stage, run `build-image.sh` in the
directory corresponding to that stage. To run the container, for manual
debugging, use `run-image.sh`. To run the automated smoke tests, use
`test-image.sh`. The tests rely on data files stored in the `test/` directory
and may write additional outputs to that same location when they run.

Stage 3 - Denovo Molecule Design
--------------------------------

TODO: Describe stage 3

Dependencies (included in Docker image):

  * Autogrow4
    * Website: <https://durrantlab.pitt.edu/autogrow4/>
    * Version: 4.0.3
  * Autodock Vina
    * Website: <https://vina.scripps.edu>
    * Version: 1.1.2

The Docker container for this stage also uses Miniconda 4.10.3 running Python
3.8 to supply a Python interpreter and various dependencies for Autogrow4, which
is in line with the recommended way to use this software.

Stage 4 - Similarity Search
---------------------------

Build fingerprints for our denovo molecules, then compare against molecules in
the database. The fingerprints for the database molecules are pre-generated and
are referenced with the :code:`molecule_db` parameter. The result of this stage
is a collection of molecules likely to be similar to the denovo molecules and
therefore (hopefully) likely to fit the receptor.

This stage consists entirely of custom code but relies on RDKit (specifically
the Python bindings), version 2021.9.4.

Stage 5 - Protein Ligand Docking
--------------------------------

TODO: Describe stage 5

Dependencies (included in Docker image):

  * Autodock Vina
    * Website: <https://vina.scripps.edu>
    * Version: 1.1.2

Stage 6 - Activity Prediction
-----------------------------

TODO: Describe stage 6

Dependencies (included in Docker image):

  * Autodock Vina
    * Website: <https://vina.scripps.edu>
    * Version: 1.1.2
  * DLIGAND2
    * Source: <https://github.com/sysu-yanglab/DLIGAND2/>
    * Commit: 03b0347d450b1a70f4728d1d170626100b585bb4
  * Smina
    * Source: <https://github.com/mwojcikowski/smina>
  * Open Babel
    * Website: <http://openbabel.org/wiki/Main_Page>
    * Installed from Debian repositories

Stage 7 - ADMET Filtering (optional)
------------------------------------

TODO: Describe stage 7

Dependencies (included in Docker image):

  * FPADMET
    * Source: <https://gitlab.com/vishsoft/fpadmet>
    * Commit: d61d63e3d3c37e887a5d4b1959260d9f1b41f77a
