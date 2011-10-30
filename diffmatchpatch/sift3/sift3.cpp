#include <QtCore>
#include "sift3.h"


Sift3::Sift3(): _maxOffset(5)
{
}

Sift3::Sift3(int maxOffset): _maxOffset(maxOffset)
{
}


float Sift3::Distance(QString s1, QString s2)
{
    if (s1.size() == 0)
        return s2.size() == 0 ? 0 : s2.size();

    if (s2.size() == 0)
        return s1.size();

    int c = 0;
    int offset1 = 0;
    int offset2 = 0;
    int lcs = 0;
    while ((c + offset1 < s1.size()) &&
           (c + offset2 < s2.size()))
    {
        if (s1[c + offset1] == s2[c + offset2]) lcs++;
        else
        {
#if V31
            c += (offset1 + offset2)/2;
            if (c >= s1.size()) c = s1.size() - 1;
            if (c >= s2.size()) c = s2.size() - 1;
#endif
            offset1 = 0;
            offset2 = 0;
            if (s1[c] == s2[c])
            {
                c++;
                continue;
            }
            for (int i = 1; i < _maxOffset; i++)
            {
                if ((c + i < s1.size())
                    && (s1[c + i] == s2[c]))
                {
                    offset1 = i;
                    break;
                }
                if ((c + i < s2.size())
                    && (s1[c] == s2[c + i]))
                {
                    offset2 = i;
                    break;
                }
            }
        }
        c++;
    }
    return (s1.size() + s2.size())/2 - lcs;
}


float Sift3::Similarity(QString s1, QString s2)
{
    float dis = Distance(s1, s2);
    float maxLen = qMax((float) qMax(s1.size(), s2.size()), dis);
    if (maxLen == 0) return 1;
    return 1 - dis/maxLen;
}

