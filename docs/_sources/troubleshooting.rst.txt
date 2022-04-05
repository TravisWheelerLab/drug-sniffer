Troubleshooting
===============

Some common issues are listed below, along with likely solutions or next steps.

**The pipeline stops running after the protein-ligand docking (PLD) stage**

This can be a sign that the stage got invalid input data. For example, if the
PDB file describing the protein receptor is improperly formatted, the PLD stage
may fail. However, since PLD jobs are allowed to fail, no error will be raised
if they *all* fail, the pipeline will simply terminate early and produce no
output.

The most common remedy is to ensure that the protein receptor file is properly
formatted.
