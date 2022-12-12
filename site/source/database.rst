.. _database:

Database
========

*Drug Sniffer* can be used with any collection of molecules as its database.
However, we provide two databases for users who do not wish to bring their own.
The first, an extremely small database, just a few dozen molecules, exists for
testing purposes. It can be found at ``examples/small-db``. The second is much,
much larger (about 450GB decompressed). This database is available for download
as a split ZIP file from `<https://data.drugsniffer.org>`_.

Specifically, the full database is available for download with the following steps in a shell environment :

::

  # download a collection of files representing the complete database. This will create
  # a new directory in your current working directory called molecule-files/
  $ mkdir molecule_db
  $ cd molecule_db
  $ wget --accept-regex "ds_" -nH -np -r https://data.drugsniffer.org/molecule-files/

  # merge all those files into a single zip file, then unzip it
  $ zip -F molecule-files/ds_molecules.zip --out molecules.zip
  $ unzip molecules.zip

  # clean up
  $ rm -rf molecules.zip molecule-files/


Once extracted, you can point Drug Sniffer at the location using the
:ref:`molecule_db-parameter` parameter.
That will be the path to (and including) the molecule_db directory described above.

