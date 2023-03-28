#!/usr/bin/env bash

# Author: Otello M Roscioni
# email om.roscioni@materialx.co.uk
# Last revision: 12 October 2020
#
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
# 
# Copyright (C) MaterialX LTD - All Rights Reserved.

# Create a linear chain of N repeating (LAC-LAC-LAC-GLY) units.
#
# USAGE: bash plga_aa_polymer.sh 25 > plga_aa_polymer25.lt

# Length of the chain
length=$1

# Definition of monomers.
la="lac_aa_01.lt"
la1="lac1_aa_01.lt"
ga="gly_aa_01.lt"
ga2="gly2_aa_01.lt"

# translation vector.
tr=( 3.25 1.60 0.00 )

# Print the LT definition of the chain.
echo "import \"$la\""
echo "import \"$la1\""
echo "import \"$ga\""
echo "import \"$ga2\""
echo
echo "PLGA$length inherits GROMOS_54A7_ATB {"
echo "  # force all monomers to share the same molecule-ID"
echo "  create_var {\$mol}"

# Create a linear chain of PLGA.
for i in $(seq 1 $length); do
  for n in $(seq 1 4); do
    j=$(bc<<<\($i-1\)*4+$n-1)
    shift=( $(bc<<<${tr[0]}*$j) $(bc<<<${tr[1]}*$j) $(bc<<<${tr[2]}*$j) )
  
    if [[ $n -eq 1 ]]; then
     if [[ $i -eq 1 ]]; then
       # First monomer of the chain.
       echo "  plga$j = new lac1.move(${shift[0]},${shift[1]},${shift[2]})"
     else
       echo "  plga$j = new lac.move(${shift[0]},${shift[1]},${shift[2]})"
     fi
    elif [[ $n -eq 2 ]]; then
     echo "  plga$j = new lac.rot(180.0, 1,0,0).rot(60.0, 0,0,1).move(${shift[0]},${shift[1]},${shift[2]})"
    elif [[ $n -eq 3 ]]; then
     echo "  plga$j = new lac.move(${shift[0]},${shift[1]},${shift[2]})"
    else
     if [[ $i -eq $length ]]; then
       # Last monomer of the chain.
       echo "  plga$j = new gly2.rot(180.0, 1,0,0).rot(60.0, 0,0,1).move(${shift[0]},${shift[1]},${shift[2]})"
     else
       echo "  plga$j = new gly.rot(180.0, 1,0,0).rot(60.0, 0,0,1).move(${shift[0]},${shift[1]},${shift[2]})"
     fi
    fi
  
  done
done
echo ""

# Extra Connectivity.
max=$(bc<<<$length*4)
echo "  write(\"Data Bonds\") {"
for i in $(seq 1 $length); do
  for n in $(seq 1 4); do
    j=$(bc<<<\($i-1\)*4+$n-1)
    k=$(bc<<<$j+1)
    
    if [[ $k -lt $max ]]; then
      # LAC-LAC
      if [[ $n -lt 3 ]]; then
       echo "    \$bond:bkb$j @bond:g20 \$atom:plga$j/C2 \$atom:plga$k/O2"
      # LAC-GLY
      elif [[ $n -eq 3 ]]; then
       echo "    \$bond:bkb$j @bond:g20 \$atom:plga$j/C2 \$atom:plga$k/O3"
      # GLY-LAC
      else
       echo "    \$bond:bkb$j @bond:g18 \$atom:plga$j/C4 \$atom:plga$k/O2"
      fi
    fi

  done
done
echo "  }"
echo ""

echo "  write(\"Data Angles\") {"
count=0
for i in $(seq 1 $length); do
  for n in $(seq 1 4); do
    j=$(bc<<<\($i-1\)*4+$n-1)
    k=$(bc<<<$j+1)
    
    if [[ $k -lt $max ]]; then
      # LAC-LAC
      if [[ $n -lt 3 ]]; then
       echo "    \$angle:bka$count @angle:g13 \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$angle:bka$count @angle:g13 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$angle:bka$count @angle:g50 \$atom:plga$j/H1 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$angle:bka$count @angle:g61 \$atom:plga$j/C2 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       
      # LAC-GLY
      elif [[ $n -eq 3 ]]; then
       echo "    \$angle:bka$count @angle:g13 \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$angle:bka$count @angle:g13 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$angle:bka$count @angle:g50 \$atom:plga$j/H1 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$angle:bka$count @angle:g61 \$atom:plga$j/C2 \$atom:plga$k/O3 \$atom:plga$k/C5"
       ((count++))
       
      # GLY-LAC
      else
       echo "    \$angle:bka$count @angle:g15 \$atom:plga$j/C5 \$atom:plga$j/C4 \$atom:plga$k/O2"
       ((count++))
       echo "    \$angle:bka$count @angle:g46 \$atom:plga$j/H5 \$atom:plga$j/C4 \$atom:plga$k/O2"
       ((count++))
       echo "    \$angle:bka$count @angle:g46 \$atom:plga$j/H6 \$atom:plga$j/C4 \$atom:plga$k/O2"
       ((count++))
       echo "    \$angle:bka$count @angle:g61 \$atom:plga$j/C4 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       
      fi
    fi

  done
done
echo "  }"
echo ""

echo "  write(\"Data Dihedrals\") {"
count=0
for i in $(seq 1 $length); do
  for n in $(seq 1 4); do
    j=$(bc<<<\($i-1\)*4+$n-1)
    k=$(bc<<<$j+1)
    
    if [[ $k -lt $max ]]; then
      # LAC-LAC
      if [[ $n -lt 3 ]]; then
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/O2 \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g39   \$atom:plga$j/O1 \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g23   \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g23   \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/H1 \$atom:plga$j/C2 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g34   \$atom:plga$j/H2 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/H3 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/H4 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g13   \$atom:plga$j/C2 \$atom:plga$k/O2 \$atom:plga$k/C3 \$atom:plga$k/C2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/C2 \$atom:plga$k/O2 \$atom:plga$k/C3 \$atom:plga$k/O1"
       ((count++))

      # LAC-GLY
      elif [[ $n -eq 3 ]]; then
       echo "    \$dihedral:bkd$count @dihedral:g39   \$atom:plga$j/O2 \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/O1 \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g23   \$atom:plga$j/C3 \$atom:plga$j/C2 \$atom:plga$k/O3 \$atom:plga$k/C5"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g23   \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O3 \$atom:plga$k/C5"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/H1 \$atom:plga$j/C2 \$atom:plga$k/O3 \$atom:plga$k/C5"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g34   \$atom:plga$j/H2 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/H3 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/H4 \$atom:plga$j/C1 \$atom:plga$j/C2 \$atom:plga$k/O3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g13   \$atom:plga$j/C2 \$atom:plga$k/O3 \$atom:plga$k/C5 \$atom:plga$k/C4"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/C2 \$atom:plga$k/O3 \$atom:plga$k/C5 \$atom:plga$k/O4"
       ((count++))

      # GLY-LAC
      else
       echo "    \$dihedral:bkd$count @dihedral:g39   \$atom:plga$j/O3 \$atom:plga$j/C5 \$atom:plga$j/C4 \$atom:plga$k/O2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/O4 \$atom:plga$j/C5 \$atom:plga$j/C4 \$atom:plga$k/O2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g23   \$atom:plga$j/C5 \$atom:plga$j/C4 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g34   \$atom:plga$j/H5 \$atom:plga$j/C4 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/H6 \$atom:plga$j/C4 \$atom:plga$k/O2 \$atom:plga$k/C3"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:g13   \$atom:plga$j/C4 \$atom:plga$k/O2 \$atom:plga$k/C3 \$atom:plga$k/C2"
       ((count++))
       echo "    \$dihedral:bkd$count @dihedral:glj14 \$atom:plga$j/C4 \$atom:plga$k/O2 \$atom:plga$k/C3 \$atom:plga$k/O1"
       ((count++))

      fi
    fi

  done
done
echo "  }"
echo ""

echo "  write(\"Data Impropers\") {"
count=0
for i in $(seq 1 $length); do
  for n in $(seq 1 4); do
    j=$(bc<<<\($i-1\)*4+$n-1)
    k=$(bc<<<$j+1)
    
    if [[ $k -lt $max ]]; then
      # LAC-LAC
      if [[ $n -lt 3 ]]; then
       echo "    \$improper:bki$count @improper:g2 \$atom:plga$j/C2 \$atom:plga$j/C1 \$atom:plga$j/C3 \$atom:plga$k/O2"
       ((count++))

      # LAC-GLY
      elif [[ $n -eq 3 ]]; then
        echo "    \$improper:bki$count @improper:g2 \$atom:plga$j/C2 \$atom:plga$j/C1 \$atom:plga$j/C3 \$atom:plga$k/O3"
       ((count++))

      fi
    fi

  done
done
echo "  }"
echo "}" 
