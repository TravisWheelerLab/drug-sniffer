#!/usr/bin/env perl

use autodie;
 
die "Usage: $0 min_jaccard [max_jaccard]\n" if ($#ARGV<0);
($min_jaccard, $max_jaccard) = @ARGV;

@files = glob("./neighbors/*.nbrs");
foreach $file (@files) {
    open F, "<$file";
    while ($line = <F>) {
        ($seed_fpt, $seed_id, $db_fpt, $db_id, $x, $y, $tanimoto) = 
                                                   split(/\s+/,$line);

        #fetch the seed smile string
        ($seed_prot, $seed_pocket) = ($seed_fpt =~ m!prints/(.+?)/fingerprints/Pocket_(\d+)!);
        $seed_smi = "/home/tw247551e/SARS-CoV2-drugs/pockets/$seed_prot/denovo/Pocket_$seed_pocket.smi";
        $seed_idx = "/home/tw247551e/SARS-CoV2-drugs/pockets/fingerprints/$seed_prot/indexes/Pocket_$seed_pocket.index";

        if ($seed_smi ne $seed_smi_prev) {
            open SEED_SMI,   "$seed_smi";
            open SEED_INDEX, "$seed_idx";
            binmode SEED_INDEX;
            $seed_smi_prev = $seed_smi;
        }
        seek SEED_INDEX, $seed_id*8, SEEK_SET;
        read(SEED_INDEX, $buffer, 8);

        $smi_offset = unpack("q>",$buffer);
        seek SEED_SMI, $smi_offset, SEEK_SET;
        $line = <SEED_SMI>;
        ($seed_smistr) =  ($line =~ /^(\S+)/);


        #fetch the db smile string and data
        $db_smi = $db_idx = $db_fpt;
        $db_smi =~ s!fingerprints_all_data/fingerprints!compounds/all_data/splits!;
        $db_smi =~ s/fpt/smi/;
        $db_idx =~ s!/fingerprints/!/indexes/!;
        $db_idx =~ s/fpt/index/;

        if ($db_smi ne $db_smi_prev) {
            open DB_SMI,   "$db_smi";
            open DB_INDEX, "$db_idx";
            binmode DB_INDEX;
            $db_smi_prev = $db_smi;
        }
        seek DB_INDEX, $db_id*8, SEEK_SET;
        read(DB_INDEX, $buffer, 8);

        $smi_offset = unpack("q>",$buffer);
        seek DB_SMI, $smi_offset, SEEK_SET;
        $line = <DB_SMI>;
        ($db_smistr, $db_src, $db_id2)   = split (/\s+/, $line);   

        $db_smi =~ /(all_data\.\d+\.smi)/;
        print "$db_smistr $db_src $1 $db_id $seed_smistr $seed_prot $seed_pocket \n";
    }
}
