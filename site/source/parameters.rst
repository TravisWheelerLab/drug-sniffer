.. _parameters:

Parameters
==========

The parameters described below can be specified when the pipeline is run. They
change the behavior of various stages.

Output
------

.. _output_dir:

output_dir
^^^^^^^^^^

A local directory in which to write the final output files, including the
aggregated results and error reports. A reasonable choice would be
``'${launchDir}/output'``.

Protein Receptor (Pocket)
-------------------------

The values below describe the protein receptor we will "grow" molecules for in
the denovo step.

receptor_pdb
^^^^^^^^^^^^

Description of the protein receptor, in PDB format.

receptor_center_x
^^^^^^^^^^^^^^^^^

X coordinate of the pocket center

receptor_center_y
^^^^^^^^^^^^^^^^^

Y coordinate of the pocket center

receptor_center_z
^^^^^^^^^^^^^^^^^

Z coordinate of the pocket center

receptor_size_x
^^^^^^^^^^^^^^^

size in the X dimension (Angstroms)

receptor_size_y
^^^^^^^^^^^^^^^

size in the Y dimension (Angstroms)

receptor_size_z
^^^^^^^^^^^^^^^

size in the Z dimension (Angstroms)

Denovo Ligands (Stage 3)
------------------------

denovo_ligands (optional)
^^^^^^^^^^^^^^^^^^^^^^^^^

A SMILES file (.smi) containing one or more SMILES strings for molecules to use
in place of building denovo ligands with Autogrow4. This causes Stage 3 to be
skipped entirely, the ligands specified will be fed directly into Stage 4.

Similarity Search (Stage 4)
---------------------------

.. _molecule-db-parameter:

molecule_db
^^^^^^^^^^^

The path to the :ref:`molecule database <molecule-db>` to use.

tanimoto_cutoff
^^^^^^^^^^^^^^^

The minimum Tanimoto coefficient to consider two molecules a match.

ADMET Filtering (Stage 7)
-------------------------

admet_checks
^^^^^^^^^^^^

A space-separated list of ADMET checks to perform, see the FPADMET documentation
for a list of available checks.
