#ifndef SIFT3_H
#define SIFT3_H

/// <summary>
/// Computes the distance and similarity between two strings
/// a lot faster than Levenshtein
/// </summary>
// Usage example:
// var ss3=new StringSift3();
// var distance=ss3.Distance(s1, s2);
// var similarity=ss3.Similarity(s1, s2);

class Sift3 {
private:
    /// <summary>
    /// describes the distance between characters at which it is
    /// cheaper to replace a character rather than move it
    /// </summary>
    int _maxOffset;

public:
    /// <summary>
    /// Instantiate the class with a default value of MaxOffset=5
    ///  </summary>
    Sift3();

    /// <summary>
    /// MaxOffset represents the maximum range the algorithm searches for the same character
    /// It is cheaper to replace a character rather than move it from a distance larger than MaxOffset.
    /// </summary>
    /// <param name="maxOffset"></param>
    Sift3(int maxOffset);

    /// <summary>
    /// Calculate a distance similar to Levenstein, but faster and less reliable.
    /// </summary>
    /// <param name="s1"></param>
    /// <param name="s2"></param>
    /// <returns></returns>
    float Distance(QString s1, QString s2);

    /// <summary>
    /// Calculate the similarity of two strings, as a percentage.
    /// </summary>
    /// <param name="s1"></param>
    /// <param name="s2"></param>
    /// <returns></returns>
    float Similarity(QString s1, QString s2);
};

#endif // SIFT3_H
