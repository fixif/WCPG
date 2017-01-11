/* Copyright 2016 by

  Laboratoire d'Informatique de Paris 6 - Équipe PEQUAN
  Sorbonne Universités
  UPMC Univ Paris 06
  UMR 7606, LIP6
  4, place Jussieu
  F-75252 Paris Cedex 05
  France

  Laboratoire d'Informatique de Paris 6, equipe PEQUAN,
  UPMC Universite Paris 06 - CNRS - UMR 7606 - LIP6, Paris, France

  Contributors:
  Anastasia Volkova anastasia.volkova@lip6.fr
  Christoph Lauter

  This software is a mathematical library whose purpose is to provide
  functions to compute the Worst-Case Peak Gain measure of Linear
  Time-Invariant Digital Filters.

  This software is governed by the CeCILL-C license under French law and
  abiding by the rules of distribution of free software.  You can  use,
  modify and/ or redistribute the software under the terms of the CeCILL-C
  license as circulated by CEA, CNRS and INRIA at the following URL
  "http://www.cecill.info".

  As a counterpart to the access to the source code and  rights to copy,
  modify and redistribute granted by the license, users are provided only
  with a limited warranty  and the software's author,  the holder of the
  economic rights,  and the successive licensors  have only  limited
  liability.

  In this respect, the user's attention is drawn to the risks associated
  with loading,  using,  modifying and/or developing or reproducing the
  software by the user in light of its specific status of free software,
  that may mean  that it is complicated to manipulate,  and  that  also
  therefore means  that it is reserved for developers  and  experienced
  professionals having in-depth computer knowledge. Users are therefore
  encouraged to load and test the software's suitability as regards their
  requirements in conditions enabling the security of their systems and/or
  data to be ensured and,  more generally, to use and operate it in the
  same conditions as regards security.

  The fact that you are presently reading this means that you have had
  knowledge of the CeCILL-C license and that you accept its terms.

  This program is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


 */


/* 
"mpfr_linalg.h" provides the prototypes for the function for:
   -complex MPFR matrix initialization/clearing
   -complex MPFR basic brick's methods, which dynamiclally adapt
   the precision of the result in order to satisfy a scalar 
   absolute error bound given in the argument such as
         - multiplyAndAdd 
         - sumAbs
         - inverse
         - checkTwoNorm
         - ComputeFrobeniusNormUpperBound
         - etc.

   Multiple Precision complex matrix is represented as two matrices holding its real
   and imaginary part. All matrices are represented as one-dimension arrays, where 
   for a n*m matrix A the element A(i,j) is the element A[i * m + j] of the array.

   ATTENTION: THE CONDITION TEST FOR MATRIX INVERSE MUST BE UPDATED.
*/

#ifndef MPFR_LINALG_H
#define MPFR_LINALG_H

#ifdef __cplusplus
extern "C" {
#endif


#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <gmp.h>
#include <mpfr.h>
#include "mpfr_matrix.h"
#include "clapack_functions_config.h"

/* Computes an upper bound on ceil(log2(max(m,n))) */
static inline uint64_t ceilLog2(uint64_t n, uint64_t m);


/* Swaps two MPFR array pointers */
static inline void swapMPFRArrayPointers(mpfr_t **p, mpfr_t **q);

/* Computes a rigorous lower bound on the Frobenius norm of a n * m
   complex matrix A, given as ReA (real part) and ImA (imaginary
   part). The function uses the MPFR variable scratch as scratch
   space, assuming it has been allocated, possibly changing its
   precision and not clearing it.  
*/
void frobeniusNormLowerBound(mpfr_t frob, mpfr_t *ReA, mpfr_t *ImA, uint64_t n, uint64_t m, mpfr_t scratch);

/* Computes a rigorous upper bound on the Frobenius norm of a n * m
   complex matrix A, given as ReA (real part) and ImA (imaginary
   part). The function uses the MPFR variable scratch as scratch
   space, assuming it has been allocated, possibly changing its
   precision and not clearing it.  
*/
void frobeniusNormUpperBound(mpfr_t frob, mpfr_t *ReA, mpfr_t *ImA, uint64_t n,uint64_t m, mpfr_t scratch);

/* Checks if the Frobenius norm of a n * m complex matrix A, given as
   ReA (real part) and ImA (imaginary part), is rigorously upper
   bounded by 2^k, k given in input. Returns a non-zero value if the
   Frobenius norm can be shown to be less than or equal to 2^k, return
   zero otherwise. The function uses the MPFR variables scratch1 and
   scratch2 as scratch space, assuming they have been
   allocated, possibly changing their precision and not clearing
   them.
*/
int checkFrobeniusNorm(mpfr_t *ReA, mpfr_t *ImA, uint64_t n,uint64_t m, mp_exp_t k, mpfr_t scratch1, mpfr_t scratch2);

/* Computes the sum of the elements of a n sized vector v with an
   overall error bounded in magnitude by 2^k, adapting the precision
   of the result variable if necessary to satisfy the absolute error
   bound. 
*/
void sumVectorWithAbsoluteErrorBound(mpfr_t sum, mpfr_t *v, uint64_t n, mp_exp_t k);

/* Computes the absolute value (modulus) of the complex number re + i
   * im with an absolute error bounded in magnitude by 2^k, adapting
   the precision of the result variable if necessary to satisfy the
   absolute error bound. The function uses the MPFR variable scratch,
   as scratch space, assuming it has been allocated, possibly changing
   its precision and not clearing it.
*/
void computeAbsoluteValue(mpfr_t res, mpfr_t re, mpfr_t im, mp_exp_t k, mpfr_t scratch);

/* Computes in the n * m real matrix C the sum of the n * m matrix A
   and the element-by-element absolute value (modulus) of the n * m
   complex matrix B, given as its real part reB and imaginary part
   imB.

   The C matrix will be such that there exists a real matrix Delta

   Delta = C - A + |B|

   for which every element Delta_ij is bounded in magnitude by 2^k:

   |Delta_ij| <= 2^k.

   The function changes the precision of the elements of matrix C
   where needed to satisfy the absolute error bound.
   
   The function uses a vector scratch of size 3 of MPFR variables as
   scratch space, assuming it has been allocated and initialized,
   possibly changing its precision and not clearing nor freeing it.

   Pointers A and C may point to the same matrix; matrices reB and imB
   must be distinct and be distinct from A and C.

 */
void accumulateAbsoluteValue(mpfr_t *C, mpfr_t *A, mpfr_t *reB, mpfr_t *imB, uint64_t n,uint64_t m, mp_exp_t k, mpfr_t *scratch);


/* Computes in the n * m real matrix B element-by-element absolute value(modulus)
  of the n * m real matrix A. 
  Pointers A and B may point to the same matrix. 
  If precision of B is less than that of A, the function increases precision 
  of matrix B (for it to be equal to the precision of A). 
*/
  void absoluteValue(mpfr_t *B, mpfr_t *A, uint64_t n, uint64_t m);



/* Computes in the m * q complex matrix D the sum of an m * q complex
   matrix C and the product of a m * n complex matrix A and n * q complex matrix B. The
   signs of the two integers signP and signS allow for the computation
   of subtraction of matrices instead of multiplication.

   Formulawise we have for signP and signS assumed in 

   signP in {-1, 1}

   signS in {-1, 1}

   a matrix D satisfying

   D = signP * A * B + signS * C + Delta

   where Delta is a m * q complex absolute error matrix.

   D will be computed such that all elements Delta_ij of Delta are
   bounded in magnitude (modulus) by 

   |Delta_ij| <= 2^t.

   All matrices A, B, C and D are given as their real and imaginary
   parts.

   The function changes the precision of the elements of matrices reD
   and imD where needed to satisfy the absolute error bound.

   The function uses a vector scratch of size 2 * n + 1 of MPFR
   variables as scratch space, assuming it has been allocated and
   initialized, possibly changing its precision and not clearing nor
   freeing it.

   All pointers to matrices must be distinct and must be distinct from 
   the pointer to the scratch space.
*/
void complexMatrixMultiplyAndAdd(mpfr_t *reD, mpfr_t *imD, 
             int signP,
             mpfr_t *reA, mpfr_t *imA,
             mpfr_t *reB, mpfr_t *imB,
             int signS, 
             mpfr_t *reC, mpfr_t *imC,
             uint64_t m,  uint64_t n,  uint64_t q,
             mp_exp_t t,
             mpfr_t *scratch);



/* Computes in the n * n complex matrix U the inverse of the n * n
   complex matrix V, using the n * n complex matrix S as a seed for an
   iterative inversion process.

   Let Delta_1 be the error defined by 

   Delta_1 = S - V^-1 

   and 

   Delta_final = U - V^-1.

   The function ensures that U is computed such that 

   ||Delta_final||_2 <= ||Delta_final||_F <= 2^p

   where ||Delta_final||_2 resp. ||Delta_final||_F are the Euclidian
   2-norm resp. the Frobenius norm of Delta_final.

   To do so, the function assumes the following:

   * ||Delta_1||_2 <= 3/8
   
   * ||V||_2 <= 3/2

   * ||V^-1||_2 <= 3/2

   It is up to the caller of the function to ensure these conditions
   are satisfied.

   Each of the complex matrices U, V and S are given by their real and
   imagniary parts. 

   The function changes the precision of the elements of matrices reU
   and imU where needed to satisfy the bound on the norm of the error, 
   which corresponds to a absolute error bound.

   The function allocates, initializes and uses scratch space which it
   clears and frees on its own.

*/
int invertComplexMatrix(mpfr_t *reU, mpfr_t *imU,
			 mpfr_t *reV, mpfr_t *imV,
			 mpfr_t *reS, mpfr_t *imS,
			 uint64_t n,
			 mp_exp_t p);

/* For a complex n x n matrix V the function checks if conditions
   for matrix inverse are satisfied,
   with S is inverse of V computed with clapack;
   This function is to be implemented as soon as new FrobeniusNormUpperBound
   function is ready.
   The function returns non-zero value in case of success and zero if check failed.
    */
int inverseConditionsTest();


/* Compute the square of absolte value for a complex number, i.e.
    res = re^2 + im^2 + delta

    such that abs(delta) <= 2^k

    Function changes precision of res if neccesary.
  */

void squareOfAbsoluteValue(mpfr_t res, mpfr_t re, mpfr_t im, mp_exp_t k, mpfr_t scratch);


/* Functions for 2-norm verification */

//The function checks if the norm(T)_2 of complex matrix T is less than 1
// It uses the Gershgorin's cercle theorem
//See article for detailes
int checkTwoNorm(mpfr_t *reT, mpfr_t *imT, uint64_t n);
// Function extracts the non-diagonal part of complex square matrix T
// Function changes the precision of results in dependence of precision of elements of T
void extractDiagonal(mpfr_t *reR, mpfr_t *imR, mpfr_t *reT, mpfr_t *imT, uint64_t n);
void maxInVector(mpfr_t maxv, double *v, uint64_t n);


#ifdef __cplusplus
}
#endif

#endif /* MPFR_LINALG_H */
