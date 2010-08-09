// Makes a floppy disk size file
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BUFSIZE	512
int main(int argc, char* argv[])
{
	char buffer[BUFSIZE];
	char fname[BUFSIZE];
	const int n_sectors=2880;
	FILE * outfile=0;

	if(argc==1) {
		sprintf(fname, "floppy.img");
	} else {
		sprintf(fname, "%s", argv[1]);
	}

	outfile=fopen (fname, "wb");
	if(!outfile){
		fprintf(stdout, "Unable to open :%s for writing ... exiting \n", fname);
		exit(1);
	}
	fprintf(stdout, "creating file: %s the size of a 1.44 Mb floppy disk.\n", fname);
	fprintf(stdout, "If you want a different filename pass it as a second argument: ex$ make_floppy adisk.floppy", fname);

	memset(buffer, 0, 512);	
	{
		int i=0;
		for(i=0; i<n_sectors; ++i){
			fwrite(buffer, sizeof(char), sizeof(buffer), outfile);
		}
	}
	fclose(outfile);
}
