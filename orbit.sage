#usage: orbit.sage.py [-h] [-v] (-s P Q | -r I J) [-rsa] [-ax | -in]
#                     [-ps | -qs | -pts] [-sym | -asym] [-o [DIM]]
#                     [-f [STRING]]
#
#Print (RSA) orbit table(s) for pairs of prime numbers p and q and check for specified symmetry
#v1.1.8 (2022-11-30) by Luca Quade
#
#Three sample calls (the 1st one prints full tables for all prime pairs between 3 and 12 and checks for symmetry along p axis;
#the 2nd only shows inner points with (point-)symmetric orbits for 5 and 7 and prints the table to out.tex;
#the 3rd shows only non-symmetric (with respect to q-symmetry) RSA orbits of axis points for p=13 and q=19):
# $ sage orbit.sage -r 3 12 -o -ps
# $ sage orbit.sage -s 5 7 -in -sym -o -f out
# $ sage orbit.sage -s 13 19 -rsa -ax -qs -asym -o
#
#optional arguments:
#  -h, --help            show this help message and exit
#  -v, --version         show program's version number and exit
#  -s P Q, --single P Q  print a single table for primes P and Q
#  -r I J, --range I J   print tables for all unique pairs of primes in range of integers I-J
#  -rsa, --rsa_orbits    examine RSA orbits (default: normal orbits)
#  -ax, --axis           show only axis points (default: show all points)
#  -in, --inner          show only inner points (default: show all points)
#  -ps, --psymmetric     examine symmetry over the p axis (default: symmetry over origin)
#  -qs, --qsymmetric     examine symmetry over the q axis (default: symmetry over origin)
#  -pts, --pointsymmetric
#                        examine symmetry over the origin (default)
#  -sym, --symmetric     show only points with symmetric orbits (default: symmetric and non-symmetric orbits)
#  -asym, --asymmetric   show only points with non-symmetric orbits (default: symmetric and non-symmetric orbits)
#  -o [DIM], --orbit [DIM]
#                        print orbits represented in specified dimension (1 or 2, default: 1)
#  -f [STRING], --file [STRING]
#                        print table(s) to specified file name (default file name: table)
#
#

__version__ = "v1.1.8 (2022-11-30)"

import argparse

# ===================================================================
# Helper functions: -------------------------------------------------

def numTables(x, y):
  #return amount of unique prime pairs between x and y
  count = 0
  for i in range(lower, upper):
    for j in range(i+1, upper+1):
      if isPrime(i) and isPrime(j):
        count+=1
  return count

def isPrime(p):
  #test if p is a prime number > 2
  if p < 3:
    return False
  for i in range(2, p):
    if p % i == 0:
      return False
  return True

def trunc(file):
  #empty file
  f = open(file, "w")
  f.close()

#===================================================================
# Define the commandline options/arguments for the argparse parser

def defineParser():

  parser = argparse.ArgumentParser(description=
            "Print (RSA) orbit table(s) for pairs of prime numbers p and q and check for specified symmetry\n"
            + __version__ + " by Luca Quade"
            + "\n\nThree sample calls (the 1st one prints full tables for all prime pairs between 3 and 12 and checks for symmetry along p axis;"
            + "\nthe 2nd only shows inner points with (point-)symmetric orbits for 5 and 7 and prints the table to out.tex;"
			+ "\nthe 3rd shows only non-symmetric (with respect to q-symmetry) RSA orbits of axis points for p=13 and q=19):"
            + "\n $ sage orbit.sage -r 3 12 -o -ps"
            + "\n $ sage orbit.sage -s 5 7 -in -sym -o -f out"
			+ "\n $ sage orbit.sage -s 13 19 -rsa -ax -qs -asym -o"
            , formatter_class=argparse.RawTextHelpFormatter)
  
  parser.add_argument("-v", "--version", action="version", version='%(prog)s  ' + __version__ )

  mgroup1 = parser.add_mutually_exclusive_group(required=True)
  mgroup1.add_argument("-s", "--single", metavar = ("P", "Q"), help="print a single table for primes P and Q", nargs=2, type=int)
  mgroup1.add_argument("-r", "--range", metavar = ("I", "J"), help="print tables for all unique pairs of primes in range of integers I-J", nargs=2, type=int)
  
  parser.add_argument("-rsa", "--rsa_orbits", help="examine RSA orbits (default: normal orbits)", action="store_true")
    
  mgroup2 = parser.add_mutually_exclusive_group()
  mgroup2.add_argument("-ax", "--axis", help="show only axis points (default: show all points)", action="store_true")
  mgroup2.add_argument("-in", "--inner", help="show only inner points (default: show all points)", action="store_true")
    
  mgroup3 = parser.add_mutually_exclusive_group()
  mgroup3.add_argument("-ps", "--psymmetric", help="examine symmetry over the p axis (default: symmetry over origin)", action="store_true")
  mgroup3.add_argument("-qs", "--qsymmetric", help="examine symmetry over the q axis (default: symmetry over origin)", action="store_true")
  mgroup3.add_argument("-pts", "--pointsymmetric", help="examine symmetry over the origin (default)", action="store_true")
    
  mgroup4 = parser.add_mutually_exclusive_group()
  mgroup4.add_argument("-sym", "--symmetric", help="show only points with symmetric orbits (default: symmetric and non-symmetric orbits)", action="store_true")
  mgroup4.add_argument("-asym", "--asymmetric", help="show only points with non-symmetric orbits (default: symmetric and non-symmetric orbits)", action="store_true")
    
  parser.add_argument("-o", "--orbit", metavar = "DIM", help="print orbits represented in specified dimension (1 or 2, default: 1)", type=int, nargs="?", const=1, default=-1)
    
  parser.add_argument("-f", "--file", metavar = "STRING", help="print table(s) to specified file name (default file name: table)", nargs="?", const="table", default="")

  return parser

# ===================================================================
# Evaluate the commandline and get the input data

def GetDataAndOptions(parser):
  args = parser.parse_args()
  if args.single is not None and not isPrime(args.single[0]):
    print("p must be a prime number. Exit."); sys.exit(1)
  elif args.single is not None and not isPrime(args.single[1]):
    print("q must be a prime number. Exit."); sys.exit(1)
  elif args.single is not None and args.single[0] == args.single[1]:
    print("p and q must be different numbers. Exit."); sys.exit(1)
  elif args.single is not None and args.single[0] < 3:
    print("p must be greater than 2. Exit."); sys.exit(1)
  elif args.single is not None and args.single[1] < 3:
    print("q must be greater than 2. Exit."); sys.exit(1)
  elif args.single is not None:
    R = False
    P, Q = args.single[0], args.single[1]
  elif args.range is not None:
    R = True
    P, Q = args.range[0], args.range[1]
    
  RSA = args.rsa_orbits

  if not args.axis and not args.inner:
    VAL = "all"
  elif args.axis:
    VAL = "axis"
  else: VAL = "inner"
    
  if args.psymmetric:
    S = "p"
  elif args.qsymmetric:
    S = "q"
  else:
    S = "pt"

  if args.symmetric:
    SYM = "sym"
  elif args.asymmetric:
    SYM = "asym"
  else: SYM = "all"
  
  if args.orbit != 1 and args.orbit != 2 and args.orbit != -1:
    print("Orbit dimension must be 1 or 2. Exit."); sys.exit(1)

  O = args.orbit

  f_name = args.file

  return P, Q, RSA, VAL, S, SYM, O, R, f_name

#====================================================================
#Generate orbit table

def p_sym_full_fast(a, p, q):
  #check for p-symmetry of full orbits

  R = Zmod(p)
  S = Zmod(q)

  #full orbits of axis points (a,0) always have p-symmetry
  if a%q == 0:
    return True
  #full orbits of axis points (0,b) are p-symmetric if they are point symmetric
  if a%p == 0:
    return pt_sym_full_fast(a, p, q)

  #full orbits of inner points (a,b) are p-symmetric if the order of b in Z_q devides a higher power of 2 than the order of a in Z_p
  ord_p = R(a).multiplicative_order()
  ord_q = S(a).multiplicative_order()
  while ord_p % 2 == 0 and ord_q % 2 == 0:
    ord_p = ord_p/2
    ord_q = ord_q/2
  if ord_q % 2 == 0:
    return True
  else: return False

def q_sym_full_fast(a, p, q):
  #check for q-symmetry of full orbits

  R = Zmod(p)
  S = Zmod(q)

  #full orbits of axis points (0,b) are always q-symmetric
  if a%p == 0:
    return True
  #full orbits of axis points (a,0) are q-symmetric if they are point symmetric
  if a%q == 0:
    return pt_sym_full_fast(a, p, q)

  #full orbits of inner points (a,b) are q-symmetric if the order of a in Z_p devides a higher power of 2 than the order of b in Z_q
  ord_p = R(a).multiplicative_order()
  ord_q = S(a).multiplicative_order()
  while ord_p % 2 == 0 and ord_q % 2 == 0:
    ord_p = ord_p/2
    ord_q = ord_q/2
  if ord_p % 2 == 0:
    return True
  else: return False

def pt_sym_full_fast(a, p, q):
  #check for point symmetry of full orbits

  R = Zmod(p)
  S = Zmod(q)

  #(0,0) is always point symmetric
  if a%p == 0 and a%q == 0:
    return True

  #the full orbit of an axis point (0,b) is point symmetric if the order of b in Z_q is even
  if a%p == 0:
    if S(a).multiplicative_order() % 2 == 0:
      return True
    else: return False

  #the full orbit of an axis point (a,0) is point symmetric if the order of a in Z_p is even
  if a%q == 0:
    if R(a).multiplicative_order() % 2 == 0:
      return True
    else: return False

  #the full orbit of an inner point (a,b) is point symmetric if the order of a in Z_p and the order of b in Z_q devide the same power >0 of 2
  ord_p = R(a).multiplicative_order()
  ord_q = S(a).multiplicative_order()
  if ord_p % 2 != 0 or ord_q % 2 != 0:
    return False
  while ord_p % 2 == 0 and ord_q % 2 == 0:
    ord_p = ord_p/2
    ord_q = ord_q/2
  if ord_p % 2 != 0 and ord_q % 2 != 0:
    return True
  else: return False
  
def p_sym_rsa_fast(a, p, q, len):
  #check for p-symmetry of rsa orbits
  
  #the rsa orbit of z is p-symmetric if the order of z is a multiple of 4 and if the full orbit of z is p-symmetric or if z%q=0
  if a%q == 0:
    return True
  if len % 4 == 0 and p_sym_full_fast(a, p, q):
    return True
  else: return False
  
def q_sym_rsa_fast(a, p, q, len):
  #check for q-symmetry of rsa orbits
  
  #the rsa orbit of z is q-symmetric if the order of z is a multiple of 4 and if the full orbit of z is q-symmetric or if z%p=0
  if a%p == 0:
    return True
  if len % 4 == 0 and q_sym_full_fast(a, p, q):
    return True
  else: return False
  
def pt_sym_rsa_fast(a, p, q, len):
  #check for point symmetry of rsa orbits
  
  #the rsa orbit of z is point symmetric if the order of z is a multiple of 4 and if the full orbit of z is point symmetric or if z=0
  if a == 0:
    return True
  if len % 4 == 0 and pt_sym_full_fast(a, p, q):
    return True
  else: return False

def p_sym_bruteforce(o, p, q):
  #check for p-symmetry of full or rsa orbit
  for i in o:
    sym = False
    for j in o:
      if i % p == j % p and (q-(i % q)) % q == j % q:
        sym = True
    if sym == False:
      return False
  return True

def q_sym_bruteforce(o, p, q):
  #check for q-symmetry of full or rsa orbit
  for i in o:
    sym = False
    for j in o:
      if (p-(i % p)) % p == j % p and i % q == j % q:
        sym = True
    if sym == False:
      return False
  return True


def pt_sym_bruteforce(o, n):
  #check for point symmetry of full or rsa orbit
  for i in o:
    if (-i % n) not in o:
      return False
  return True

def generateOrbit(a, n):
  #generate orbit of a in Z_n
  orbit = []
  x=a
  
  #if a is in Z_n^*, the length of <a> is the order of a in Z_n
  if a != 0 and gcd(a,n)==1:
    R = Zmod(n)
    ord=R(a).multiplicative_order()
    for i in range(ord):
      orbit.append(x)
      x=x*a%n
  else:
    while True:
      if orbit and orbit[0] == x:
        break
      orbit.append(x)
      x=x*a%n
  return orbit

def generateOrbitRSA(a, n, exp):
  #generate RSA orbit of a in Z_n
  orbit = []
  for e in exp:
    x = power_mod(a, e, n)
    if x not in orbit:
      orbit.append(x)
  return orbit

def generateTable(p, q, rsa, val, s, sym, orb):
  #check different properties of orbits in Z_n and return them as table

  rows = []
  if orb != -1:
    columns = ['a', "(a % p, a % q)", "<a>", "Length of <a>", "Length of <a%p>", "Length of <a%q>", "Sym?", "Duplicate?"]
  else: columns = ['a', "(a % p, a % q)", "Length of <a>", "Length of <a%p>", "Length of <a%q>", "Sym?", "Duplicate?"]
  rows.append(columns)
  n = p*q
  R = Zmod(p)
  S = Zmod(q)
  T = Zmod(n)

  #generate orbits
  orbits = []
  
  if rsa:
    exp = []
    for i in range(1, (p-1)*(q-1)):
      if gcd(i, (p-1)*(q-1)) == 1:
        exp.append(i)
    for a in range(0, n):
      if val == "all" or val == "axis" and (a % p == 0 or a % q == 0) or val == "inner" and a % p != 0 and a % q != 0:
        if a%p == 0 and a%q == 0:
          orbit_length = 1
        elif a%p == 0:
          orbit_length = S(a%q).multiplicative_order()
        elif a%q == 0:
          orbit_length = R(a%p).multiplicative_order()
        else: orbit_length = T(a).multiplicative_order()
        if (sym == "all" or
            sym == "sym" and ((s == "p" and p_sym_rsa_fast(a, p, q, orbit_length)) or (s == "q" and q_sym_rsa_fast(a, p, q, orbit_length)) or (s == "pt" and pt_sym_rsa_fast(a, p, q, orbit_length))) or 
            sym == "asym" and ((s == "p" and not p_sym_rsa_fast(a, p, q, orbit_length)) or (s == "q" and not q_sym_rsa_fast(a, p, q, orbit_length)) or (s == "pt" and not pt_sym_rsa_fast(a, p, q, orbit_length)))):
          orbits.append(generateOrbitRSA(a, n, exp))
  
    
  else:
    for a in range(0, n):
      if val == "all" or val == "axis" and (a % p == 0 or a % q == 0) or val == "inner" and a % p != 0 and a % q != 0:
        if (sym == "all" or
          sym == "sym" and ((s == "p" and p_sym_full_fast(a, p, q)) or (s == "q" and q_sym_full_fast(a, p, q)) or (s == "pt" and pt_sym_full_fast(a, p, q))) or 
          sym == "asym" and ((s == "p" and not p_sym_full_fast(a, p, q)) or (s == "q" and not q_sym_full_fast(a, p, q)) or (s == "pt" and not pt_sym_full_fast(a, p, q)))):
          orbits.append(generateOrbit(a, n))

  #generate table entries
  for i in range(0, len(orbits)):
    o = orbits[i]
    row = []
    
    row.append(str(o[0]))
    row.append("(" + str(o[0] % p) + "," + str(o[0] % q) + ")")
    
    #check if duplicate orbit
    dup = -1
    for j in range(0, i):
      if set(orbits[j]) == set(o):
        dup = orbits[j][0]
        break
    if dup != -1:
      if orb != -1:
        row.append("")
      row.extend(["", "", "", "", "<" + str(o[0]) + "> = <" + str(dup) + ">"])
    else:
      #print orbit if wanted
      if orb != -1:
        orb_str = "["
        for orb_el in o:
          if orb == 1:
            orb_str += str(orb_el)
          else:
            orb_str += "(" + str(orb_el % p) + "," + str(orb_el % q) + ")"
          if orb_el == o[-1]:
            orb_str += "]"
          else: orb_str += ", "
        row.append(orb_str)
        
      row.append(str(len(o)))
      if o[0] % p != 0:
        row.append(str(R(o[0]).multiplicative_order()))
      else: row.append(str(1))
      if o[0] % q != 0:
        row.append(str(S(o[0]).multiplicative_order()))
      else: row.append(str(1))
    
      #check for symmetry
      if sym == "sym":
        row.append("y")
      elif sym == "asym":
        row.append("n")
      elif rsa == True:
        if (s == "p" and p_sym_rsa_fast(o[0], p, q, len(o)) or (s == "q" and q_sym_rsa_fast(o[0], p, q, len(o))) or (s == "pt" and pt_sym_rsa_fast(o[0], p, q, len(o)))):
          row.append("y")
        else: row.append("n")
      else: 
        if (s == "p" and p_sym_full_fast(o[0], p, q)) or (s == "q" and q_sym_full_fast(o[0], p, q)) or (s == "pt" and pt_sym_full_fast(o[0], p, q)):
          row.append("y")
        else: row.append("n")
      row.append("")
    rows.append(row)
  return rows

# ===================================================================
#Print TeX commands of orbit table to file

def toTex(tab, file, orbit, p, q):
  f = open(file, "a")
  tab_lines = "|c|c|c|c|c|c|c|"
  orb_col = ""
  if orbit != -1:
    tab_lines += "c|"
    orb_col += r"& $\langle a \rangle$ "
  
  f.writelines(["\\begin{table}[h!]\n", 
                "\\begin{tabular}{" + tab_lines + "}\n", 
                "\\hline\n", 
                r"$a$ & ($a \% p$, $a \% q$) " + orb_col + r"& $|\langle a \rangle|$ & $|\langle a\% p \rangle|$ & $|\langle a\% q \rangle|$ & Sym? & Duplicate? \\" + "\n",
                "\\hline\n"])
  
  for row in tab:
    if row != tab[0]:
      row_str = ""
      for entry in row:
        if entry != "" and entry[0] == "[":
          row_str += "$"
          count = 0
          for i in entry:
            row_str += i
            if i == ",":
              count += 1
              if count > 0 and count % 5 == 0:
                row_str += r"$\newpage $"
          row_str += "$ & "
        elif entry != "" and entry[0] == "<":
          row_str += "$"
          for i in entry:
            if i == "<":
              row_str += r"\langle "
            elif i == ">":
              row_str += r"\rangle "
            else: row_str += i
          row_str += "$"
        else:
          if str(entry) != "" and str(entry) != "y" and str(entry) != "n":
            row_str += "$" + str(entry) + "$"
          else: row_str += str(entry)
          if entry != row[-1]:
            row_str += " & "
      row_str += r" \\" + "\n"
      f.write(row_str)
       
  f.writelines(["\\hline\n", 
                "\\end{tabular}\n", 
                "\\caption{Orbits in $\\mathbb{Z}_{" + str(p*q) + "} \\cong \\mathbb{Z}_{" + str(p) + "} \\times \\mathbb{Z}_{" + str(q) + "}$}\n", 
                r"\end{table}" + "\n\n"])
  f.close()
    
    
# ===================================================================
# ===================================================================

if __name__ == "__main__":

  
  #get inputs from parser
  parser = defineParser()
  P, Q, RSA, VAL, S, SYM, O, R, f_name = GetDataAndOptions(parser)

  #clear file for later writing
  if f_name:
    f_name += ".tex"
    trunc(f_name)
  
  #generate and print orbit table(s)
  if not R:
    tab = generateTable(P, Q, RSA, VAL, S, SYM, O)
    print("\n Table for p = ", P, " and q = ", Q, ":\n", sep = "")
    print(table(tab, header_row=True), "\n")
    if f_name:
      toTex(tab, f_name, O, P, Q)
  else:
    if P < Q:
      lower, upper = P, Q
    else: lower, upper = Q, P
    print("\nPrinting", numTables(lower, upper), "tables:\n")
    for i in range(lower, upper):
      for j in range(i+1, upper+1):
        if isPrime(i) and isPrime(j):
          tab = generateTable(i, j, RSA, VAL, S, SYM, O)
          print("\n Table for p = ", i, " and q = ", j, ":\n", sep = "")
          print(table(tab, header_row=True), "\n")
          if f_name:
            toTex(tab, f_name, O, i, j)