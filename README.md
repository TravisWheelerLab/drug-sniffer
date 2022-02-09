# Drug Sniffer

TODO: Write a brief introduction / description

## Usage

TODO: Explain how to run in various environments

## Testing

The `data/` directory contains data and configuration for end-to-end testing.

## Workflow

The `workflow/` directory contains everything necessary to run the Drug Sniffer
workflow conveniently on a variety of computing platforms.  The individual
components of the workflow (stages) are described below.

TODO: Describe the overall workflow (diagram?)

Each stage includes a Docker image (`Dockerfile`) along with dependencies and
scripts. To build the image, run `build-image.sh`. To run it, for manual
debugging, use `run-image.sh`. To run the automated smoke tests, use
`test-image.sh`. The tests rely on data files stored in the `test/` directory
and will write additional outputs to that same location when they run.

### Stage 3 - Denovo Molecule Design

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

### Stage 5 - Protein Ligand Docking

TODO: Describe stage 5

Dependencies (included in Docker image):

  * Autodock Vina
    * Website: <https://vina.scripps.edu>
    * Version: 1.1.2

### Stage 6 - Activity Prediction

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

### Stage 7 - ADMET Filtering

TODO: Describe stage 7

Dependencies (included in Docker image):

  * FPADMET
    * Source: <https://gitlab.com/vishsoft/fpadmet>
    * Commit: d61d63e3d3c37e887a5d4b1959260d9f1b41f77a

