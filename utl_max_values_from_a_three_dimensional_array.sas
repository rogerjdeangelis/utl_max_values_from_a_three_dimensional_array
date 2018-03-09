Max values over the last dimension of a three dimensional array

github
https://github.com/rogerjdeangelis/utl_max_values_from_a_three_dimensional_array

Same results with SAS and WPS

  Two solutions

      1. Base SAS/WPS
      2. WPS/PROC R or SAS/IML/R
      3. Rick's IML solution on end

see
https://tinyurl.com/ycgjsmqs
http://r.789695.n4.nabble.com/maximum-over-one-dimension-of-a-3-dimensional-array-td885169.html


INPUT (Three 2 by 2 arrays)
===========================

 Three 2 by 2 arrays


  Z=1
     Y1  Y2

  X1  3   4
  X2  7  10


  Z=2
     Y1  Y2

  X1  2   5
  X2  8  11


  Z=3
     Y1  Y2

  X1  1   6
  X2  9  12


 WANT

     Y1  Y2

  X1  3   6
  X2  9  12



PROCESS
=======

 1. Base SAS/WPS

     data want;

       array mat[2,2,3] (3,2,1,4,5,6,7,8,9,10,11,12);
       array out[2,2];
           do x= 1 to 2;
             do y=1 to 2;
               out[x,y]=max(mat[x,y,1],mat[x,y,2],mat[x,y,3]);
           end;
         end;
         do x=1 to 2;
           put out[x,1]   out[x,2]  ;
         end;

     run;quit;


 2. WPS/PROC R or SAS/IML/R (working code)

    x <- array(c(3,7,4,10,2,8,5,11,1,9,6,12),c(2,2,3));
    want<-apply(x, c(1,2), max);


OUTPUT
======

  BASE SAS/WPS (put statement)

  3 6
  9 12


 WPS/PROC RR

  WORK.WANTWPS total obs=2

     V1    V2

      3     6
      9    12

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data is in script

   WPS/SAS
     array mat[2,2,3] (3,2,1,4,5,6,7,8,9,10,11,12);

   R
     x <- array(c(1,2,3,4,5,6,7,8,9,10,11,12),c(2,2,3))

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

* SAS/WPS;

%utl_submit_wps64('
data want;

  array mat[2,2,3] (3,2,1,4,5,6,7,8,9,10,11,12);
  array out[2,2];
      do x= 1 to 2;
        do y=1 to 2;
          out[x,y]=max(mat[x,y,1],mat[x,y,2],mat[x,y,3]);
      end;
    end;
    do x=1 to 2;
      put out[x,1]   out[x,2]  ;
    end;

run;quit;
');


WPS/R;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
x <- array(c(3,7,4,10,2,8,5,11,1,9,6,12),c(2,2,3));
want<-apply(x, c(1,2), max);
endsubmit;
import r=want  data=wrk.wantwps;
run;quit;
');


Rick Wicklin via listserv.uga.edu

We can solve this problem more generally and more compactly. Suppose
there are p variables and you want the maximum product of k.  (Roger has
hard-coded the case p=4 and k=3.)  You can use the ALLCOMB function in SAS
to generate all the combinations of p objects taken k at a time. Use
these as indices into the array of variables. Now take the maximum product of the possible combina
tions for each observation. In SAS/IML, this can be done as follows:

proc iml;
use have; read all var _num_ into X; close;
p = ncol(X);
k = 3;
c = allcomb(p, k);  /* combinations of p items taken k at a time */

maxMul = j(nrow(X), 1);
do i = 1 to nrow(X);
   Y = X[i,];                   /* get i_th row */
   M = shape(Y[c], nrow(c), k); /* all combinations of elements */
   maxMul[i] = max( M[,#] );    /* max of product of rows */
end;

print maxMul;



