exonerate-gff3
==============

[![CI](https://github.com/hotdogee/exonerate-gff3/actions/workflows/ci.yml/badge.svg)](https://github.com/hotdogee/exonerate-gff3/actions/workflows/ci.yml)

This is an [exonerate](https://web.archive.org/web/20150318011821/http://www.ebi.ac.uk/~guy/exonerate/) fork with added GFF3 support.

Exonerate is Guy Slater's general purpose tool for biological sequence comparison. Its models include spliced alignment of proteins, ESTs and cDNAs to genomes. This fork is based on exonerate 2.2.0 and adds one option, `--gff3`. With it, alignments to a genome are written as GFF3 `match` / `match_part` features that genome browsers and annotation pipelines can load directly.

What this fork adds
-------------------

New option:

```
--gff3 [FALSE]
Generate GFF3 output instead of GFF2
```

Using the `--gff3 yes` option with the `--showtargetgff yes` option will output GFF3. Without the `--gff3 yes` option, everything works just as before, so previous scripts relying on the old output format won't break. The GFF2 output is the same as upstream exonerate 2.2.0 apart from the version string.

With `--gff3 yes`:

* The output starts with a single `##gff-version 3` line.
* Each alignment is a `match` feature on the target sequence, with the alignment score in column 6 and these attributes:
  * `ID=matchNNNNN`, numbered from `match00001` in each run
  * `Name=` the query sequence ID
  * `Target=` the query ID, start and end, plus the strand when it is known
  * `Gap=` the alignment as `M` / `I` / `D` operations
* Each exon of the alignment is a `match_part` feature whose `Parent=` is the match ID. Viewers that don't read the `Gap` attribute still show the aligned blocks. (When this was written in 2014, JBrowse didn't support `Gap`.)

Notes:

* GFF3 is written for target-side GFF (`--showtargetgff`) with the models that align to a genomic target: `est2genome`, `protein2genome`, `coding2genome`, `cdna2genome` and `genome2genome`. For other models, and for `--showquerygff`, `--gff3 yes` prints only the header.
* Use `--verbose 0` to get a clean GFF3 file. At the default verbosity, exonerate also writes `Command line:`, `Hostname:` and `-- completed exonerate analysis` lines to standard output.
* This fork reports itself as `exonerate version 2.3.0`.

Building
--------

You need a C compiler (GCC or Clang), `make`, `pkg-config` and the GLib 2 development files.

Debian / Ubuntu:

```sh
sudo apt-get install build-essential pkg-config libglib2.0-dev
```

Fedora:

```sh
sudo dnf install gcc make pkgconf-pkg-config glib2-devel
```

Then build, test and install:

```sh
./configure            # e.g. ./configure --prefix=$HOME/.local to install without root
make
make check
sudo make install      # optional; installs into /usr/local by default
```

The build generates and compiles C code for each alignment model, so it takes a while. Run `./configure --help` for the options. The upstream [README](README) has more build and performance notes.

`configure` and the `Makefile.in` files are committed, so you don't need autoconf or automake to build. If you change `configure.in` or a `Makefile.am`, run `autoreconf -fi` before `./configure`.

Usage
-----

A quick example with the test data in this repository. Run it from the top of the source tree after `make`:

```sh
src/program/exonerate --model protein2genome \
    --query test/data/protein/calm.human.protein.fasta \
    --target test/data/cdna/calm.human.dna.fasta \
    --showvulgar no --showalignment no \
    --showtargetgff yes --gff3 yes --verbose 0
```

Output:

```
##gff-version 3
EMBL:J04046	exonerate:protein2genome:local	match	104	550	759	+	.	ID=match00001;Name=CALM_HUMAN;Target=CALM_HUMAN 1 149;Gap=M447
EMBL:J04046	exonerate:protein2genome:local	match_part	104	550	.	+	.	Parent=match00001
EMBL:J04046	exonerate:protein2genome:local	match	137	331	165	+	.	ID=match00002;Name=CALM_HUMAN;Target=CALM_HUMAN 85 149;Gap=M195
EMBL:J04046	exonerate:protein2genome:local	match_part	137	331	.	+	.	Parent=match00002
```

Example command for mapping proteins to a genome assembly:

```sh
exonerate -q protein.fa -t genome.fa --model protein2genome --querytype protein --targettype dna --showvulgar no --softmaskquery yes --softmasktarget yes --minintron 20 --maxintron 3000 --showalignment no --showtargetgff yes --showcigar no --geneseed 250 --score 250 --verbose 0 --gff3 yes
```

Example output (spliced alignments get one `match_part` per exon):

```
Scaffold1	exonerate:protein2genome:local	match	188318	189587	649	-	.	ID=match00012;Name=EDAN000750-PA;Target=EDAN000750-PA 1 129 +;Gap=M135 D884 M251
Scaffold1	exonerate:protein2genome:local	match_part	189452	189587	.	-	.	Parent=match00012
Scaffold1	exonerate:protein2genome:local	match_part	188318	188568	.	-	.	Parent=match00012
Scaffold1	exonerate:protein2genome:local	match	183667	183897	392	-	.	ID=match00013;Name=EDAN000750-PA;Target=EDAN000750-PA 127 203;Gap=M231
Scaffold1	exonerate:protein2genome:local	match_part	183667	183897	.	-	.	Parent=match00013
Scaffold1	exonerate:protein2genome:local	match	45007	45165	265	-	.	ID=match00014;Name=EDAN000738-PA;Target=EDAN000738-PA 10 62;Gap=M159
Scaffold1	exonerate:protein2genome:local	match_part	45007	45165	.	-	.	Parent=match00014
Scaffold1	exonerate:protein2genome:local	match	218654	221996	1577	+	.	ID=match00015;Name=EDAN000753-PA;Target=EDAN000753-PA 1 337 +;Gap=M30 D61 M100 D61 M127 D373 M181 D56 M225 D1183 M189 D604 M153
Scaffold1	exonerate:protein2genome:local	match_part	218654	218685	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	218745	218846	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	218906	219034	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	219406	219586	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	219643	219867	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	221051	221239	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	221844	221996	.	+	.	Parent=match00015
```

Run `exonerate --help` for all the other options. They are the same as upstream.

Testing
-------

`make check` runs the upstream test suite plus `test/exonerate/exonerate.gff3.test.sh`. That test runs the bundled sequences through `protein2genome` (forward and reverse strand) and `est2genome` with `--gff3 yes`. It checks the header, the 9 columns, the feature types and the `match` / `match_part` links. It also checks that output without `--gff3` is still GFF2. CI runs the same steps on every push and pull request.

Credits and license
-------------------

Exonerate was written by Guy St C. Slater at the EBI, with contributions from the people listed in [AUTHORS](AUTHORS). The original website is offline, but an [archived copy](https://web.archive.org/web/20150318011821/http://www.ebi.ac.uk/~guy/exonerate/) still has the beginner's and advanced user guides and the man pages. If you use exonerate, please cite:

> Slater GSC, Birney E. Automated generation of heuristics for biological sequence comparison. *BMC Bioinformatics* 2005, 6:31. [doi:10.1186/1471-2105-6-31](https://doi.org/10.1186/1471-2105-6-31)

GFF3 support by Han Lin ([@hotdogee](https://github.com/hotdogee)).

Like upstream exonerate, this fork is distributed under the GNU General Public License, version 3. See [COPYING](COPYING).
