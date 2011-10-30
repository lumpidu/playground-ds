#include <stdio.h>
#include <string.h>

#define MAXLEN 80
int findMin(int d1, int d2, int d3) {
   /*
    * return min of d1, d2 and d3.
    */
   if(d1 < d2 && d1 < d3)
       return d1;
   else if(d1 < d3)
       return d2;
   else if(d2 < d3)
       return d2;
   else
      return d3;
}

int findEditDistance(const char *s1, const char *s2) {
    /*
     * returns edit distance between s1 and s2.
     */
   int d1, d2, d3;

   if(*s1 == 0)
       return strlen(s2);
   if(*s2 == 0)
       return strlen(s1);
   if(*s1 == *s2)
       d1 = findEditDistance(s1+1, s2+1);
   else
       d1 = 1 + findEditDistance(s1+1, s2+1);    // update.
   d2 = 1+findEditDistance(s1, s2+1);                   // insert.
   d3 = 1+findEditDistance(s1+1, s2);                   // delete.

   return findMin(d1, d2, d3);
}

#if 0
int main() {
    char s1[MAXLEN], s2[MAXLEN];

    printf("Enter string 1: ");
    gets(s1);

    while(*s1) {
        printf("Enter string 2: ");
        gets(s2);
        printf("Edit distance(%s, %s) = %d.\n", s1, s2, findEditDistance(s1, s2));
        printf("Enter string 1(enter to end): ");
        gets(s1);
    }

    return 0;
}
#endif
