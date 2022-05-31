#!/usr/bin/env python3

from argparse import ArgumentParser


def main(args):
    parser = ArgumentParser(
        "process_results.py",
        description="A script to process Drug Sniffer results",
    )

    parser.add_argument("--ligand-smi")
    parser.add_argument("--ligand-score")
    parser.add_argument("--admet-output")
    parser.add_argument("--admet-checks")

    options = parser.parse_args(args)

    admet_checks = options.admet_checks.split()

    headers = [
        "pose",
        "chemical name",
        "chemical database",
        "smiles",
        "dock2bind score",
    ]
    for check in admet_checks:
        headers.append(f"predicted {check}")
        headers.append(f"confidence {check}")
        headers.append(f"credibility {check}")
    headers.append("logp")

    print("\t".join(headers))

    ligand_file = open(options.ligand_smi, "r")
    score_file = open(options.ligand_score, "r")
    admet_file = open(options.admet_output, "r")

    ligand_lines = list(ligand_file)
    score_lines = list(score_file)
    admet_lines = list(admet_file)

    assert len(ligand_lines) == len(score_lines)
    assert len(ligand_lines) == len(admet_lines)

    # All results have their corresponding SMI line at the beginning of
    # each record, and all SMI lines are unique (so there are no ties),
    # so we can put the results for each stage in a consistent order by
    # sorting them all.
    ligand_lines.sort()
    score_lines.sort()
    admet_lines.sort()

    for ligand, score, admet in zip(ligand_lines, score_lines, admet_lines):
        smi, name, db, _ = ligand.split("\t")
        smi_score, name_score, db_score, _, pose, value = score.split("\t")

        admet_parts = admet.split("\t")
        assert len(admet_parts) == 5 + 3 * len(admet_checks)
        smi_admet, name_admet, db_admet, _ = admet[:4]

        try:
            assert smi.strip() == smi_score.strip()
            assert name.strip() == name_score.strip()
            assert db.strip() == db_score.strip()

            assert smi.strip() == smi_admet.strip()
            assert name.strip() == name_admet.strip()
            assert db.strip() == db_admet.strip()
        except:
            print(f"ligand: {ligand}")
            print(f"score: {score}")
            print(f"admet: {admet}")
            raise

        print(
            "\t".join(
                [
                    pose.strip(),
                    name.strip(),
                    db.strip(),
                    smi.strip(),
                    value.strip(),
                ] + admet_parts[4:],
            )
        )

    score_file.close()
    admet_file.close()


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
