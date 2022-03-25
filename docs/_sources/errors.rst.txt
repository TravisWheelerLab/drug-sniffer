.. _errors:

Errors
======

The *Drug Sniffer* pipeline produces two output files. One of them is an error
log (``all_errors.txt``) that contains a list of recoverable errors that
occurred at particular stages.

For example, if a certain pose fails to parse, the pipeline can still continue
and report results, but the error will be included in the error report so that
the user can decide how to proceed.

Each of the possible errors is documented below, grouped by the stage in which
it can occur.

Stage 5
-------

``failed converting receptor to pdbqt`` - the receptor PDB file
could not be converted to a PDBQT file with MGLTools.

``failed converting ligand to pdbqt: ...`` - the given ligand could not be
converted to PDBQT format using Open Babel.

``failed docking ligand: ...`` - the given ligand could not be docked using
Autodock Vina.

Stage 6
-------

``failed converting receptor to pdbqt`` - the receptor PDB file could not be
converted to a PDBQT file with Open Babel.

``failed running vina_split: ...`` - Autodock Vina failed to split the given
PDBQT file into its component poses.

``failed converting pose to mol2: ...`` - the given pose could not be converted
to MOL2 format using Open Babel.

``failed running dfire: ...`` - DFIRE failed to run on the given pose.

``failed running smina: ...`` - Smina failed to run on the given pose.

``failed creating poses: ...`` - all poses contained in the given PDBQT file
failed on a previous step, so no activity prediction could be made.

``failed running dock2bind model`` - the Dock2Bind model failed to run.
