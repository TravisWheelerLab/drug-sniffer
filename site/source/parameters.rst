Parameters
==========

The parameters described below can be specified when the pipeline is run. They
change the behavior of various stages.

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

Search and Similarity
---------------------

.. _molecule-db-parameter:

molecule_db
^^^^^^^^^^^

The path to the molecule database to use.

tanimoto_cutoff
^^^^^^^^^^^^^^^

The minimum Tanimoto coefficient to consider two molecules a match.
