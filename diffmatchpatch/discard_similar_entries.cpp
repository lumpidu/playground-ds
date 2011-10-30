#include <iostream>
#include <QtCore>
#include "diff_match_patch.h"
#include "sift3.h"

extern int distance(const QString source, const QString target);
extern int findEditDistance(const char *s1, const char *s2);

QStringList stringlist;
float matchLevel=0.1;
Sift3 sift(12);

//
// Map Function
// analyzes all index values i+1..stringlist.size()
// for matching string occurences and returns all
// indizes in a list below a certain levenshtein distance
//
QList<int> calcsimil(const int &i)
{
    QList<int> list;
    QString str1 = stringlist.at(i).trimmed();

    if ((str1.size() < 200) || (str1.startsWith("==============")) || (str1.startsWith(" ==============")))
    {
        return list;
    }

    list << i;

    int lev;
    for (int j = i+1; j < stringlist.size(); ++j)
    {
        QString str2 = stringlist.at(j).trimmed();

        if (str2.startsWith("=============") || str2.startsWith(" ============="))
            continue;

        lev = sift.Distance(str1, str2);

        if (lev > str1.size()*1.2)
        {
            // too unsimilar: goto next element
            break;
        }

        if (lev < str1.size()*matchLevel)
        {
            // very close match
            // we could additionally calc. the real
            // levenstein distance if we wanted ...
            list << j;
        }
    }
    return list;
}


void reduce(QList<int> &result, const QList<int> &tmp)
{
    if (tmp.size() != 0)
    {
        for (int i=1; i<tmp.size(); ++i)
        {
            result << tmp.at(i);
        }

        qDebug() << tmp;
        fflush(stderr);fflush(stdout);
    }
}

int main(int argc, char** argv)
{
    if (argc < 2)
    {
        std::cout << "Input file argument missing !" << std::endl;
        exit (1);
    }

    // argument argv[1] contains the input file name
    // output will go to stdout

    QFile file(argv[1]);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << "File doesn't exist:" << argv[1];
        exit(1);
    }

    QFile file_out(QString(argv[1])+".cleaned");
    if (!file_out.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        qDebug() << "Could not open for writing: " << file_out.fileName();
        exit(1);
    }

    QTextStream in(&file);
    do
    {
        QString line = in.readLine();
        stringlist << line;
        // process_line(line);
    //} while ((!in.atEnd()) && (stringlist.size() < 42000));
    } while (!in.atEnd());

    QList<int> allIndexes;
    for (int i=0; i<stringlist.size(); ++i)
    {
        allIndexes << i;
    }

    // Use Mapped Reduce for parallel processing ...
    qDebug() << "Start processing " << file.fileName() << " ...";
    QFuture<QList<int> > calcing = QtConcurrent::mappedReduced(allIndexes, calcsimil, reduce);
    calcing.waitForFinished();

    // now make matching line numbers unique
    QSet<int> match_lines = calcing.result().toSet();
qDebug() << match_lines;
    // write cleaned up version to output file
    QTextStream out(&file_out);
    size_t nlines=0;
    for (int i=0; i<stringlist.size(); ++i)
    {
        if ((! match_lines.contains(i)) && (stringlist[i].size() > 200))
        {
            out << stringlist[i] << "\n";
            nlines++;
        }
    }
    qDebug() << "Wrote " << nlines << "Lines to " << file_out.fileName();
    qDebug() << "Finished.";

    return 0;
}
