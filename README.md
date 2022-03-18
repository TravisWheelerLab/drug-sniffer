# Drug Sniffer

_Drug Sniffer_ is a virtual screening (VS) pipeline capable of screening
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
FP-ADMET, an ADMET filter (stage 7).

The _Drug Sniffer_ pipeline has been implemented as a
[Nextflow](http://nextflow.io) workflow. Each stage has a corresponding script
and Docker image that are used to execute the computations contained in the
stage.

![Drug Sniffer Workflow](https://user-images.githubusercontent.com/42721626/157732342-2f03485e-38ae-4c60-8d9f-9b71f9d47919.png)

## Documentation

The project documentation can be found at <http://drugsniffer.org>.

## About the Repo

End-to-end tests and associated data are stored in `test/`. The workflow itself,
implemented using Nextflow, can be found in `workflow/`.

The `site/` directory contains the project web site source code. The HTML and
other assorted files live in the `docs/` directory where they can be served by
GitHub Pages.

## Contributing

Contributions are welcome. Fork this repository, modify the contents, and then
create a pull request. Someone will look over it and provide feedback, then
merge it when it is ready.

## License

Original code and configuration are under the BSD 3-clause license. Third-party
software is licensed separately.

