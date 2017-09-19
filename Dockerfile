# Dockerfile to build images that will generate a modified CNS 1.21 for XL-MS Protein assembly (XL-MOD) with a working directory set up as described at http://aria.pasteur.fr/supplementary-data/x-links/readme/view  .
# *** NOTE: THE FILE `cns_solve_1.21_all-mp.tar.gz` MUST BE PROVIDED, SEE BELOW. This Dockerfile will handle everything else needed to produce a system set up with the code at http://aria.pasteur.fr/supplementary-data/x-links ready to run. ***
# Citation and abstract for the software:
# Automated structure modeling of large protein assemblies using crosslinks as distance restraints.
# Ferber M, Kosinski J, Ori A, Rashid UJ, Moreno-Morcillo M, Simon B, Bouvier G, Batista PR, Müller CW, Beck M, Nilges M.
# Nat Methods. 2016 Jun;13(6):515-20. doi: 10.1038/nmeth.3838. Epub 2016 Apr 25.                    PMID: 27111507
# Abstract
# Crosslinking mass spectrometry is increasingly used for structural characterization of multisubunit protein complexes. Chemical crosslinking captures 
# conformational heterogeneity, which typically results in conflicting crosslinks that cannot be satisfied in a single model, making detailed modeling a
# challenging task. Here we introduce an automated modeling method dedicated to large protein assemblies ('XL-MOD' software is available at 
# http://aria.pasteur.fr/supplementary-data/x-links) that (i) uses a form of spatial restraints that realistically reflects the distribution of
# experimentally observed crosslinked distances; (ii) automatically deals with ambiguous and/or conflicting crosslinks and identifies alternative 
# conformations within a Bayesian framework; and (iii) allows subunit structures to be flexible during conformational sampling. We demonstrate our method 
# by testing it on known structures and available crosslinking data. We also crosslinked and modeled the 17-subunit yeast RNA polymerase III at atomic 
# resolution; the resulting model agrees remarkably well with recently published cryoelectron microscopy structures and provides additional insights into 
# the polymerase structure.
# https://www.ncbi.nlm.nih.gov/pubmed/27111507  
FROM ubuntu:16.04
LABEL maintainer "Wayne Decatur *(fomightez on Github)*"

# Install container-wide requrements gcc, python pip, zlib, libssl, make,
# libncurses, fortran77, g++, unzip, nano, wget, screen #
# plus some stuff specific to cnssolve: csh, byacc flex
RUN apt-get update && apt-get install -y libreadline-dev \
   gcc \
   make \
   zlib1g-dev \
   build-essential \
   python2.7-dev \
   python-numpy \
   python-matplotlib \
   python-pip \
   libssl-dev \
   libncurses5-dev \
   gfortran \
   g++ \
   wget \
   curl \
   unzip \
   nano \
   screen \
   libbz2-dev \
   liblzma-dev \
   libpcre3-dev \
   libcurl4-openssl-dev \
   libgsl0-dev \
   software-properties-common \
   libtbb-dev \
   libicu-dev \
   xorg-dev \
   libxml2-dev \
   csh \
   byacc flex \
 && rm -rf /var/lib/apt/lists/*  && \

   wget -O /opt/get-pip.py --no-check-certificate https://bootstrap.pypa.io/get-pip.py && \
   python /opt/get-pip.py && \
   rm -f /opt/get-pip.py && \






# getting Fortran g77 compiler  on Ubuntu >=14.04
# to do combining https://askubuntu.com/questions/837618/need-the-gnu-g77-fortran-compiler-on-ubuntu-16-04-having-issues and https://gist.github.com/ygmpkk/4088b9648efbcc584e5a
# And to undo changes to sources list for apt-get to address "David Foerster suggests in the comments that mixing Ubuntu versions is a bad idea. So I should mention that after installing g77 I would then usually edit the /etc/apt/sources.list file again and comment out the 8.04 repos:" by combining https://askubuntu.com/questions/837618/need-the-gnu-g77-fortran-compiler-on-ubuntu-16-04-having-issues and ephemient's answer at https://stackoverflow.com/questions/1584066/append-to-etc-apt-sources-list this so apt-get sources not messed up after pointing at old one to get g77 compiler for fortran . Used https://stackoverflow.com/questions/40336473/dockerfile-cant-copy-files-cp-command to get around issue with copying via COPY. I think COPY is for one have file on machine that is bulding the image.

    echo 'deb http://old-releases.ubuntu.com/ubuntu/ hardy universe' > /tmp/oldreleases.list && \
    echo 'deb-src http://old-releases.ubuntu.com/ubuntu/ hardy universe' >> /tmp/oldreleases.list && \
    echo 'deb http://old-releases.ubuntu.com/ubuntu/ hardy-updates universe' >> /tmp/oldreleases.list && \
    echo 'deb-src http://old-releases.ubuntu.com/ubuntu/ hardy-updates universe' >> /tmp/oldreleases.list && \
    mv /tmp/oldreleases.list /etc/apt/sources.list.d/ && \
    apt-get update -y && apt-get -y upgrade && \
    apt-get install -y g77 && \
#Undo source change
    rm -rf /etc/apt/sources.list.d/oldreleases.list && \
    apt-get update -y && apt-get -y upgrade



# Now to place `cns_solve_1.21_all-mp.tar.gz` from a previous download into the image being build. The `cns_solve_1.21_all-mp.tar.gz` file must be downloaded and placed in the same directory with the Dockerfile being used in the course of the build. The source of this file is http://cns-online.org/download/ .
COPY cns_solve_1.21_all-mp.tar.gz /cns/



# Set working directory to /cns and unpack. 
WORKDIR /cns/
RUN tar -zxvf cns_solve_1.21_all-mp.tar.gz && \



# Following along with Step #2 at http://aria.pasteur.fr/supplementary-data/x-links/readme/view , get "CNS_modified_sources.tar" archive from http://aria.pasteur.fr/supplementary-data/x-links/cns_modified_sources/view , uncompress it, and copy the contents into the `source` directory of CNS.
    wget -O CNS_modified_sources.tar http://aria.pasteur.fr/supplementary-data/x-links/cns_modified_sources/at_download/file && \
    tar -zxvf CNS_modified_sources.tar && \
    mv cns_source_for_XLMS/*.* cns_solve_1.21/source/ && \
    sed -i "s|READ (FLIST(UNIT),'(I)') NATOMX|READ (FLIST(UNIT),'(I6)') NATOMX|g" /cns/cns_solve_1.21/source/dynio.f && \
    sed -i "s|READ(FLIST(UNIT),'(I)') I|READ(FLIST(UNIT),'(I6)') I|g" /cns/cns_solve_1.21/source/dynio.f && \
    rm -f CNS_modified_sources.tar && \




# Return to dealing with the preparation of compiling the CNS software. Need to set the location correctly in cns_solve_env to let `make install` and running resulting compiled program work, and then do four edits so that don't otherwise get errors about MXFPEPS2 and machine epsilon following approach suggested by srinivas_penumutchu at http://ask.bioexcel.eu/t/cns-errors-before-after-recompilation/54/14. Finally compile cns_solve.
    sed -i "s|setenv CNS_SOLVE '_CNSsolve_location_'|setenv CNS_SOLVE '/cns/cns_solve_1.21'|g" /cns/cns_solve_1.21/cns_solve_env && \
    sed -i "s|PARAMETER (MXFPEPS2=1024)|PARAMETER (MXFPEPS2=8192)|g" /cns/cns_solve_1.21/source/machvar.inc && \
    sed -i 's|echo "   static-fastm|#echo "   static-fastm|g' /cns/cns_solve_1.21/Makefile && \
    sed -i "s|PARAMETER (MXRTP=2000)|PARAMETER (MXRTP=4000)|g" /cns/cns_solve_1.21/source/rtf.inc && \
    head -66 /cns/cns_solve_1.21/source/machvar.f > newmachvar.f && \
    echo '        WRITE (6,'\''(I6,E10.3,E10.3)'\'') I, ONEP, ONEM' >> newmachvar.f  && \
    tail -n +67 /cns/cns_solve_1.21/source/machvar.f >> newmachvar.f  && \
    mv newmachvar.f /cns/cns_solve_1.21/source/machvar.f && \
    cd cns_solve_1.21;make install && \
    rm -f cns_solve_1.21_all-mp.tar.gz







# Following along with the last two stes at http://aria.pasteur.fr/supplementary-data/x-links/readme/view , get the "Cross-links modeling.zip" archive from http://aria.pasteur.fr/supplementary-data/x-links/cross-links-modeling/at_download/file, unzip it, and place symblic link to the `cns` software within that newly unpacked directory. Plus there has to be a few instances of special editing and renaming of files to make it so the provided `00.run.sh` will run as expected in the resulting container filesystem.
WORKDIR /xlmod/
RUN wget -O Cross_links_modeling.zip http://aria.pasteur.fr/supplementary-data/x-links/cross-links-modeling/at_download/file && \
    unzip Cross_links_modeling.zip && \
    rm -f Cross_links_modeling.zip && \
    cd Cross-links\ modeling/  && \
    ln -s /cns/cns_solve_1.21/intel-x86_64bit-linux/bin/cns cns  && \
    mv 03.make_lys_restraints.inp 04.make_lys_restraints.inp  && \
    mv 04.make_restraints.inp 03.make_restraints.inp  && \
    sed -i "s|cns='cns' #name of symbolic link|cns='./cns' #name of symbolic link|g" /xlmod/Cross-links\ modeling/00.run.sh && \
    sed -i "s|scripts/10.simulation.inp|10.simulation.inp|g" /xlmod/Cross-links\ modeling/00.run.sh && \




# clean (This may be uneccsary because I thought I saw defautl action now is to handle this to make smaller containers/images, but I reallt want to be sure I fixed smy apt-get sources list and so adding this from https://github.com/jhipster/jhipster-docker/blob/master/Dockerfile)
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*




# Default command
WORKDIR /xlmod
CMD ["bash"]

### DOCKER FILE ENDS AT THIS POINT ########----------------------------------------------
# GUIDE TO WHAT TO DO WITH IT: BULDING THE IMAGE AND RUNNING THE SOFTWARE.
# Place the file `cns_solve_1.21_all-mp.tar.gz`, obtainable from 
# http://cns-online.org/download/, in a folder on your machine along with this 
# Dockerfile.
# Run the build of the image with `docker build -t xlmod .`
# (DO THIS FOLLOWING MKDIR STEP ONLY FIRST TIME; BEST TO CHECK YOU DON'T ALREADY 
# HAVE SUCH A FOLDER FIRST.) In a command line console on your local computer 
# make a directory on  your machine by typing `mkdir /data`, without the  
# surrounding tick marks. You can access it on your machine at any time by 
# `cd /data` and it will be at the top of your file hierarchy, even higher than 
# your current user directory.
# Start the container from the image with 
# `docker run -v /data:/data -it xlmod`, or to start detached use 
# `docker run -v /data:/data -itd xlmod`.
# That command, in addition to starting a container running based on the image,
#  will mount the `/data` folder on your local machine with `/data` directory 
# within the running container. This will be a bridge to supplying and 
# retrieving data files between the running container and your local machine 
# system. Any files placed in that directory from within your running container 
# will be accessible on your local drive's sytem and time, and eve after the 
# container is done running/exited. I.E., files placed here are not erased when 
# ephemeral container is stopped/exited. Because it is easy to clobber files 
# whle working on the command line where there is no trash bin, it is 
# suggested your only place copies of files in the `/data` directory from within
# your local system and you copy any out you want to be sure you have before 
# beginning another session.
# If you started it detached, attach the docker container first. Go to the 
# directory `/xlmod/Cross-links\ modeling/`, by entering 
# `cd /xlmod/Cross-links\ modeling/ and type `bash 00.run.sh` to run the 
# shell script with the example set up by the XL-mods authors.
# CTRL-C allows you to exit the running process and return to the command line 
# of the running container.
# To directly run CNS, go to `/cns/cns_solve_1.21/intel-x86_64bit-linux/bin/`, 
# by entering `cd /cns/cns_solve_1.21/intel-x86_64bit-linux/bin/`, and type 
# `./cns` or `./cns_solve` to run the programs.
# CTRL-Z allows you to exit the CNS programs and return to the command line of  
# the running container.
# Run `sudo apt-get update` first if you need to install anything later.
