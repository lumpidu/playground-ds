#QT += sql xml network
TEMPLATE = app
CONFIG += qt debug_and_release sift3

mac {
  CONFIG -= app_bundle
}

# don't embed the manifest for now (doesn't work :( )
#CONFIG -= embed_manifest_exe 

FORMS =

HEADERS = diff_match_patch.h diff_match_patch_test.h \
    sift3.h

SOURCES = diff_match_patch.cpp diff_match_patch_test.cpp discard_similar_entries.cpp \
    levenshtein.cpp \
    levenshtein2.cpp \
    sift3.cpp

RESOURCES = 
