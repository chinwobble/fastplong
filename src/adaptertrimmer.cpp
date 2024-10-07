#include "adaptertrimmer.h"

AdapterTrimmer::AdapterTrimmer(){
}


AdapterTrimmer::~AdapterTrimmer(){
}


bool AdapterTrimmer::trimByMultiSequences(Read* r, FilterResult* fr, vector<string>& adapterList, bool incTrimmedCounter) {
    int matchReq = 4;
    if(adapterList.size() > 16)
        matchReq = 5;
    if(adapterList.size() > 256)
        matchReq = 6;
    bool trimmed = false;

    string* originalSeq = r->mSeq;
    for(int i=0; i<adapterList.size(); i++) {
        trimmed |= trimBySequence(r, NULL, adapterList[i], matchReq);
    }

    if(trimmed) {
        string adapter = originalSeq->substr(r->length(), originalSeq->length() - r->length());
        if(fr)
            fr->addAdapterTrimmed(adapter, incTrimmedCounter);
        else
            cerr << adapter << endl;
    }

    return trimmed;
}

bool AdapterTrimmer::trimBySequence(Read* r, FilterResult* fr, string& adapterseq, int matchReq) {
    const int allowOneMismatchForEach = 8;

    int rlen = r->length();
    int alen = adapterseq.length();

    const char* adata = adapterseq.c_str();
    const char* rdata = r->mSeq->c_str();

    if(alen < matchReq)
        return false;

    int pos=0;
    bool found = false;
    int start = 0;
    if(alen >= 16)
        start = -4;
    else if(alen >= 12)
        start = -3;
    else if(alen >= 8)
        start = -2;
    // we start from negative numbers since the Illumina adapter dimer usually have the first A skipped as A-tailing
    for(pos = start; pos<rlen-matchReq; pos++) {
        int cmplen = min(rlen - pos, alen);
        int allowedMismatch = cmplen/allowOneMismatchForEach;
        int mismatch = 0;
        bool matched = true;
        for(int i=max(0, -pos); i<cmplen; i++) {
            if( adata[i] != rdata[i+pos] ){
                mismatch++;
                if(mismatch > allowedMismatch) {
                    matched = false;
                    break;
                }
            }
        }
        if(matched) {
            found = true;
            break;
        }

    }

    if(found) {
        if(pos < 0) {
            string adapter = adapterseq.substr(0, alen+pos);
            r->mSeq->resize(0);
            r->mQuality->resize(0);
            if(fr) {
                fr->addAdapterTrimmed(adapter);
            }

        } else {
            string adapter = r->mSeq->substr(pos, rlen-pos);
            r->resize(pos);
            if(fr) {
                fr->addAdapterTrimmed(adapter);
            }
        }
        return true;
    }

    return false;
}

bool AdapterTrimmer::test() {
    Read r("@name",
        "TTTTAACCCCCCCCCCCCCCCCCCCCCCCCCCCCAATTTTAAAATTTTCCCCGGGG",
        "+",
        "///EEEEEEEEEEEEEEEEEEEEEEEEEE////EEEEEEEEEEEEE////E////E");
    string adapter = "TTTTCCACGGGGATACTACTG";
    bool trimmed = AdapterTrimmer::trimBySequence(&r, NULL, adapter);
    if (*r.mSeq != "TTTTAACCCCCCCCCCCCCCCCCCCCCCCCCCCCAATTTTAAAA")
        return false;

    Read read("@name",
        "TTTTAACCCCCCCCCCCCCCCCCCCCCCCCCCCCAATTTTAAAATTTTCCCCGGGGAAATTTCCCGGGAAATTTCCCGGGATCGATCGATCGATCGAATTCC",
        "+",
        "///EEEEEEEEEEEEEEEEEEEEEEEEEE////EEEEEEEEEEEEE////E////EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
    vector<string> adapterList;
    adapterList.push_back("GCTAGCTAGCTAGCTA");
    adapterList.push_back("AAATTTCCCGGGAAATTTCCCGGG");
    adapterList.push_back("ATCGATCGATCGATCG");
    adapterList.push_back("AATTCCGGAATTCCGG");
    trimmed = AdapterTrimmer::trimByMultiSequences(&read, NULL, adapterList);
    if (*read.mSeq != "TTTTAACCCCCCCCCCCCCCCCCCCCCCCCCCCCAATTTTAAAATTTTCCCCGGGG") {
        cerr << read.mSeq << endl;
        return false;
    }

    return true;
}