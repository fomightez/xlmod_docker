# xlmod_docker
Dockerfile to build images that will generate a modified CNS 1.21 for XL-MS Protein assembly (XL-MOD) with a working directory set up as described as http://aria.pasteur.fr/supplementary-data/x-links/readme/view  .

**NOTE**: THE FILE `cns_solve_1.21_all-mp.tar.gz` MUST BE PROVIDED, SEE BELOW. This Dockerfile will handle everything else to result in a freshly compiled version that will run.


Citation and abstract for the software
--------------------------------------

[Automated structure modeling of large protein assemblies using crosslinks as distance restraints.  
Ferber M, Kosinski J, Ori A, Rashid UJ, Moreno-Morcillo M, Simon B, Bouvier G, Batista PR, Müller CW, Beck M, Nilges M.
Nat Methods. 2016 Jun;13(6):515-20. doi: 10.1038/nmeth.3838. Epub 2016 Apr 25.                    PMID: 27111507](https://www.ncbi.nlm.nih.gov/pubmed/27111507)

**Abstract**  
Crosslinking mass spectrometry is increasingly used for structural characterization of multisubunit protein complexes. Chemical crosslinking captures 
conformational heterogeneity, which typically results in conflicting crosslinks that cannot be satisfied in a single model, making detailed modeling a
challenging task. Here we introduce an automated modeling method dedicated to large protein assemblies (`XL-MOD` software is available at 
http://aria.pasteur.fr/supplementary-data/x-links) that (i) uses a form of spatial restraints that realistically reflects the distribution of
experimentally observed crosslinked distances; (ii) automatically deals with ambiguous and/or conflicting crosslinks and identifies alternative 
conformations within a Bayesian framework; and (iii) allows subunit structures to be flexible during conformational sampling. We demonstrate our method 
by testing it on known structures and available crosslinking data. We also crosslinked and modeled the 17-subunit yeast RNA polymerase III at atomic 
resolution; the resulting model agrees remarkably well with recently published cryoelectron microscopy structures and provides additional insights into 
the polymerase structure.


Contents of built image
-----------------------

A Linux-based Docker container with modified, freshly compiled CNSsolve 1.21 able to run the scripts for XL-MS Protein assembly (XL-MOD)

Includes:

* Ubuntu-flavor Linux base
* modified CNSsolve 1.21
* working directory for XL-MOD from [here](http://aria.pasteur.fr/supplementary-data/x-links), set up as described [here](http://aria.pasteur.fr/supplementary-data/x-links/readme/view)

*Specific versions and sources are made clear in [the Dockerfile](https://github.com/fomightez/xlmod_docker/blob/master/Dockerfile).*  

Use
----

See the bottom of [the Dockerfile](https://github.com/fomightez/xlmod_docker/blob/master/Dockerfile) for steps to use it.
