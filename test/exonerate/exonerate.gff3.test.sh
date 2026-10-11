#!/bin/sh
# regression test for GFF3 output (--gff3 yes --showtargetgff yes)

EXONERATE="../../src/program/exonerate"
FASTAREVCOMP="../../src/util/fastarevcomp"
DATADIR="${srcdir:-.}/../data"
QUERY="$DATADIR/protein/calm.human.protein.fasta"
TARGET="$DATADIR/cdna/calm.human.dna.fasta"

OUTPUTFILE="exonerate.gff3.test.out"
REVCOMPFILE="exonerate.gff3.test.revcomp.fasta"

OPTIONS="--showvulgar no --showalignment no --showtargetgff yes --verbose 0"

clean_exit(){
    rm -f $OUTPUTFILE $REVCOMPFILE
    exit $1
    }

fail(){
    echo "FAILED: $1"
    echo "--- output ---"
    cat $OUTPUTFILE
    clean_exit 1
    }

# Check that a file is well-formed GFF3 made of match/match_part features:
# header on the first line, 9 tab separated columns, valid coordinates,
# unique match IDs and match_part Parents that point at an earlier match.
check_gff3(){
    awk -F'\t' '
    function bad(msg){
        printf("line %d: %s\n", NR, msg)
        failed = 1
        exit 1
        }
    NR == 1 {
        if($0 != "##gff-version 3")
            bad("first line is not ##gff-version 3")
        next
        }
    /^##gff-version/ { bad("repeated ##gff-version directive") }
    /^#/ { next }
    {
        if(NF != 9)
            bad("expected 9 tab separated columns, found " NF)
        if(($4 !~ /^[0-9]+$/) || ($5 !~ /^[0-9]+$/) || ($4 < 1) || ($4 > $5))
            bad("invalid start/end: " $4 " " $5)
        if($6 !~ /^(\.|-?[0-9]+)$/)
            bad("invalid score: " $6)
        if($7 !~ /^[-+.?]$/)
            bad("invalid strand: " $7)
        if($8 !~ /^[.012]$/)
            bad("invalid phase: " $8)
        id = ""
        parent = ""
        n = split($9, attribute, ";")
        if(n < 1)
            bad("no attributes")
        for(i = 1; i <= n; i++){
            eq = index(attribute[i], "=")
            if(eq < 2)
                bad("invalid attribute: " attribute[i])
            key = substr(attribute[i], 1, eq-1)
            if(key == "ID")
                id = substr(attribute[i], eq+1)
            if(key == "Parent")
                parent = substr(attribute[i], eq+1)
            }
        if($3 == "match"){
            if(id == "")
                bad("match without ID")
            if(id in start)
                bad("duplicate ID " id)
            start[id] = $4+0
            end[id] = $5+0
            strand[id] = $7
            matches++
        } else if($3 == "match_part"){
            if(!(parent in start))
                bad("match_part with unknown Parent " parent)
            if(($4+0 < start[parent]) || ($5+0 > end[parent]))
                bad("match_part outside its parent match")
            if($7 != strand[parent])
                bad("match_part strand differs from its parent match")
            parts++
        } else {
            bad("unexpected feature type " $3)
            }
        }
    END {
        if(failed)
            exit 1
        if(NR == 0){
            print "empty output"
            exit 1
            }
        if((matches < 1) || (parts < 1)){
            print "expected at least one match and one match_part"
            exit 1
            }
        printf("%d match and %d match_part features\n", matches, parts)
        }' $OUTPUTFILE
    }

# Print columns 1-9 of the first match line, separated by "|"
first_match(){
    awk -F'\t' '$3 == "match" {
        print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9
        exit
        }' $OUTPUTFILE
    }

# 1. protein2genome against the forward strand
$EXONERATE --query "$QUERY" --target "$TARGET" --model protein2genome \
           $OPTIONS --gff3 yes > $OUTPUTFILE || fail "exonerate exited non-zero"
check_gff3 || fail "protein2genome output is not valid GFF3"
EXPECTED="EMBL:J04046|exonerate:protein2genome:local|match|104|550|759|+|.|ID=match00001;Name=CALM_HUMAN;Target=CALM_HUMAN 1 149;Gap=M447"
[ "`first_match`" = "$EXPECTED" ] \
    || fail "unexpected first match: `first_match`"
echo "GFF3 protein2genome (+ strand) OK"

# 2. protein2genome against the reverse complement: coordinates must be
#    reported on the forward strand of the target, with strand "-"
$FASTAREVCOMP "$TARGET" > $REVCOMPFILE || fail "fastarevcomp exited non-zero"
$EXONERATE --query "$QUERY" --target $REVCOMPFILE --model protein2genome \
           $OPTIONS --gff3 yes > $OUTPUTFILE || fail "exonerate exited non-zero"
check_gff3 || fail "reverse strand output is not valid GFF3"
EXPECTED="EMBL:J04046|exonerate:protein2genome:local|match|1626|2072|759|-|.|ID=match00001;Name=CALM_HUMAN;Target=CALM_HUMAN 1 149;Gap=M447"
[ "`first_match`" = "$EXPECTED" ] \
    || fail "unexpected first match: `first_match`"
echo "GFF3 protein2genome (- strand) OK"

# 3. est2genome (gapped alignments give I and D operations in Gap)
$EXONERATE --query "$TARGET" --target "$TARGET" --model est2genome \
           $OPTIONS --gff3 yes > $OUTPUTFILE || fail "exonerate exited non-zero"
check_gff3 || fail "est2genome output is not valid GFF3"
grep 'Gap=M[0-9]* [ID][0-9]' $OUTPUTFILE > /dev/null \
    || fail "expected a Gap attribute with insertions or deletions"
echo "GFF3 est2genome OK"

# 4. Without --gff3 the output must stay upstream GFF2
$EXONERATE --query "$QUERY" --target "$TARGET" --model protein2genome \
           $OPTIONS > $OUTPUTFILE || fail "exonerate exited non-zero"
grep '^##gff-version 3' $OUTPUTFILE > /dev/null \
    && fail "GFF2 output contains a ##gff-version 3 header"
grep '^##gff-version 2' $OUTPUTFILE > /dev/null \
    || fail "GFF2 output lacks its ##gff-version 2 header"
echo "GFF2 output without --gff3 OK"

# 5. --gff3 without a GFF option must not put a header in front of the
#    default alignment and vulgar output
$EXONERATE --query "$QUERY" --target "$TARGET" --model protein2genome \
           --verbose 0 --gff3 yes > $OUTPUTFILE || fail "exonerate exited non-zero"
grep '^##gff-version' $OUTPUTFILE > /dev/null \
    && fail "--gff3 without a GFF option printed a ##gff-version header"
grep '^vulgar:' $OUTPUTFILE > /dev/null \
    || fail "expected the default vulgar output"
echo "--gff3 without a GFF option OK"

# 6. --showquerygff has no GFF3 writer, so --gff3 prints only the header
$EXONERATE --query "$QUERY" --target "$TARGET" --model protein2genome \
           --showvulgar no --showalignment no --showquerygff yes \
           --verbose 0 --gff3 yes > $OUTPUTFILE || fail "exonerate exited non-zero"
[ "`cat $OUTPUTFILE`" = "##gff-version 3" ] \
    || fail "--showquerygff with --gff3 should print only the GFF3 header"
echo "GFF3 with --showquerygff OK"

clean_exit 0
