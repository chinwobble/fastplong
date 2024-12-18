#include <gtest/gtest.h>
#include "../src/fastqreader.h"

#include "config.h"
#include <vector>

TEST(fastqreader, test)
{
	FastqReader reader1(FP_TESTDATA_R1);

	Read *r1 = NULL;

	std::vector<Read*> v;
	while (true)
	{
		r1 = reader1.read();
		if (r1 == nullptr) {
			break;
		}
		v.push_back(r1);
	}
	EXPECT_EQ(v.size(), 9);
	EXPECT_EQ(*v[0]->mName, "@AS500713:64:HFKJJBGXY:1:11101:1675:1101 1:A:0:TATAGCCT+GACCCCCA");
	EXPECT_EQ(*v[0]->mSeq, "");
	EXPECT_EQ(*v[0]->mStrand, "+");
	EXPECT_EQ(*v[0]->mQuality, "");

	EXPECT_EQ(*v[1]->mName, "@AS500713:64:HFKJJBGXY:1:11101:17113:1101 1:A:0:TATAGCCT+GTTTCTTA");
	EXPECT_EQ(*v[1]->mSeq, "TACAAAATGCACATCGCTGAAAGGGGTAAAGGAGAGAAATCGCTTTATAAAACCTTGAAAAGGAATATTCAAATATAAGCTGGGAAGGTATAAAAAACTCTGTACATCACAAGTAAACAAATGGAACCTGCAAAATATTAAACAAAGGATT");
	EXPECT_EQ(*v[1]->mStrand, "+");
	EXPECT_EQ(*v[1]->mQuality, "AAAAAEEEEE6EEAAAEEEEE6EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEAEEEEAEEEEEEEEEEEEEEEEECFE####EEEE6EE<AAEEEAEEEEEEEEEEEEAEEEEEEEA<E/AAEEEAEEEEE/EEEEAAEEE");
}
