Parameters
==========

The parameters described below can be specified when the pipeline is run. They
change the behavior of various stages.

Search and Similarity
---------------------

molecule_db
^^^^^^^^^^^

The path to the molecule database to use.

tanimoto_cutoff
^^^^^^^^^^^^^^^

The minimum Tanimoto coefficient to consider two molecules a match.

Protein Pocket
--------------

The values below describe the protein pocket we will "grow" molecules for in the
denovo step.

pocket_pdb
^^^^^^^^^^

Description of the protein pocket, in PDB format.

pocket_center_x
^^^^^^^^^^^^^^^



pocket_center_y
^^^^^^^^^^^^^^^



pocket_center_z
^^^^^^^^^^^^^^^



pocket_size_x
^^^^^^^^^^^^^



pocket_size_y
^^^^^^^^^^^^^



pocket_size_z
^^^^^^^^^^^^^


