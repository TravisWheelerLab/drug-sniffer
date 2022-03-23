//% gcc -O3 -mpopcnt -o neighbors neighbors.c

#include <stdio.h>
#include <sys/stat.h>
#include <stdint.h>
#include <smmintrin.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>

int main (int argc, char *argv[]) {

    int i,j,k;
    int a = 0;
    int b = 0;
    uint64_t *A; //place to store an bunch of 1024-bit seed vectors (each: 16x64-bit ints)
    uint64_t B[16]; //store the 2nd 1024-bit vector
    uint64_t X,U;
    uint64_t Xcnt, Ucnt;
    float jaccard;
    FILE *f;
    FILE *dbfile;
    ssize_t read;  
    
    struct stat st;
    long int pos;
    char *seed_filename;
    char *db_filelist;
    char db_filename[2048]; 
    size_t len;

    long int seed_cnt;
    float jaccard_cutoff;

    if (argc != 4) {
        printf("Usage: %s ligand_fingerprints db_fingerprint_files tanimoto_cutoff\n", argv[0]);
        exit(1);
    }
    seed_filename  = argv[1];
    db_filelist    = argv[2];
    jaccard_cutoff = atof(argv[3]);

    //read the fingerprint for the seeds
    f = fopen(seed_filename, "rb");
    stat(seed_filename, &st);
    pos = st.st_size;
    seed_cnt = pos/128;
    A = (uint64_t*)malloc(pos * sizeof(char)); 
    fread(A, pos, 1, f); 
    fclose(f);
   
    //go through the db files
    dbfile = fopen(db_filelist, "r");
    if (dbfile == NULL){
        printf("problem opening %s\n", db_filelist);
        exit(EXIT_FAILURE);
    }

    while ( fgets (db_filename, 2048 , dbfile) != NULL ){
        db_filename[strcspn(db_filename,"\n")] = 0;//remove a newline
        //printf("[%s]\n", db_filename);
        //start at the beginning of db file, to compare all
        f = fopen(db_filename, "rb");
        if ( f == NULL ) {
            printf( "Could not open file %s\n",db_filename  ) ;
            return 1;
        }
        b=-1;
        
        while ( fread(&B, sizeof(uint64_t), 16, f) == 16) {
            b++;
            //loop over all seeds ini seed_file
            for (a=0;a<seed_cnt;a++) {
                Xcnt = Ucnt = 0; 
                for(i=0;i<16;i++) {
                    X = A[a*16+i] & B[i];
                    U = A[a*16+i] | B[i];
                    Xcnt += _mm_popcnt_u64(X);
                    Ucnt += _mm_popcnt_u64(U);
                }
                jaccard = (1.0*Xcnt)/Ucnt;

                if (jaccard>jaccard_cutoff) {
                    /*denovo_filename
                    denovo_idx
                    db_filename
                    db_idx
                    */
                    printf("%s %d %s %d %d %d %.4f\n", 
                        seed_filename,
                        a,
                        db_filename, 
                        b, 
                        Xcnt, 
                        Ucnt, 
                        jaccard);
                }
            }
        }
        
        fclose(f);
    }   
    fclose(dbfile);
    return 0;

}
