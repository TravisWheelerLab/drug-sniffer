# Drug Sniffer

_Drugsniffer_ is a  virtual screening (VS) pipeline capable of screening billions of molecules using only thousands of CPU hours, using a novel combination of ligand-based (LBVS) and structure-based (SBVS) methods. The pipeline requires the user to identify the structure and pocket of the target protein (steps 1 and 2). The pipeline begins by designing multiple de novo ligands for identified binding pockets (step 3), then uses them as seeds to identify similar compounds from small-molecule libraries (step 4). The resulting neighbors are subjected to rigid-body docking (step 5) and re-ranked with a new scoring model (step 6). An optional final step allows the user to run possible ligands through FP-ADMET, an ADMET filter (step 7). Each step of the _drugsniffer_ has been implemented as a module. Users can replace any of the supplied modules with their favorite software. 
![Amit_workflow_21-5-19_v2](https://user-images.githubusercontent.com/42721626/157732342-2f03485e-38ae-4c60-8d9f-9b71f9d47919.png)

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

