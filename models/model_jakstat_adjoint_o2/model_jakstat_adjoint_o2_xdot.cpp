
#include <include/symbolic_functions.h>
#include <include/amici_defines.h> //realtype definition
typedef amici::realtype realtype;
#include <cmath> 

void xdot_model_jakstat_adjoint_o2(realtype *xdot, const realtype t, const realtype *x, const realtype *p, const realtype *k, const realtype *h, const realtype *w) {
  xdot[0] = w[2]*(k[1]*p[3]*x[8]-k[0]*p[0]*w[0]*x[0]);
  xdot[1] = p[1]*w[1]*-2.0+p[0]*w[0]*x[0];
  xdot[2] = p[1]*w[1]-p[2]*x[2];
  xdot[3] = w[3]*(k[0]*p[2]*x[2]-k[1]*p[3]*x[3]);
  xdot[4] = p[3]*(w[4]-x[4]);
  xdot[5] = p[3]*(x[4]-x[5]);
  xdot[6] = p[3]*(x[5]-x[6]);
  xdot[7] = p[3]*(x[6]-x[7]);
  xdot[8] = p[3]*(x[7]-x[8]);
  xdot[9] = -w[0]*x[0]-p[0]*w[0]*x[9]+k[1]*p[3]*w[2]*x[17];
  xdot[10] = w[0]*x[0]+p[0]*w[0]*x[9]-p[1]*x[1]*x[10]*4.0;
  xdot[11] = -p[2]*x[11]+p[1]*x[1]*x[10]*2.0;
  xdot[12] = -p[3]*x[12]+k[0]*p[2]*w[3]*x[11];
  xdot[13] = p[3]*x[12]*2.0-p[3]*x[13];
  xdot[14] = p[3]*x[13]-p[3]*x[14];
  xdot[15] = p[3]*x[14]-p[3]*x[15];
  xdot[16] = p[3]*x[15]-p[3]*x[16];
  xdot[17] = p[3]*x[16]-p[3]*x[17];
  xdot[18] = -p[0]*w[0]*x[18]+k[1]*p[3]*w[2]*x[26];
  xdot[19] = w[1]*-2.0+p[0]*w[0]*x[18]-p[1]*x[1]*x[19]*4.0;
  xdot[20] = w[1]-p[2]*x[20]+p[1]*x[1]*x[19]*2.0;
  xdot[21] = -p[3]*x[21]+k[0]*p[2]*w[3]*x[20];
  xdot[22] = p[3]*x[21]*2.0-p[3]*x[22];
  xdot[23] = p[3]*x[22]-p[3]*x[23];
  xdot[24] = p[3]*x[23]-p[3]*x[24];
  xdot[25] = p[3]*x[24]-p[3]*x[25];
  xdot[26] = p[3]*x[25]-p[3]*x[26];
  xdot[27] = -p[0]*w[0]*x[27]+k[1]*p[3]*w[2]*x[35];
  xdot[28] = p[0]*w[0]*x[27]-p[1]*x[1]*x[28]*4.0;
  xdot[29] = -x[2]-p[2]*x[29]+p[1]*x[1]*x[28]*2.0;
  xdot[30] = -p[3]*x[30]+k[0]*w[3]*x[2]+k[0]*p[2]*w[3]*x[29];
  xdot[31] = p[3]*x[30]*2.0-p[3]*x[31];
  xdot[32] = p[3]*x[31]-p[3]*x[32];
  xdot[33] = p[3]*x[32]-p[3]*x[33];
  xdot[34] = p[3]*x[33]-p[3]*x[34];
  xdot[35] = p[3]*x[34]-p[3]*x[35];
  xdot[36] = k[1]*w[2]*x[8]-p[0]*w[0]*x[36]+k[1]*p[3]*w[2]*x[44];
  xdot[37] = p[0]*w[0]*x[36]-p[1]*x[1]*x[37]*4.0;
  xdot[38] = -p[2]*x[38]+p[1]*x[1]*x[37]*2.0;
  xdot[39] = -x[3]-p[3]*x[39]+k[0]*p[2]*w[3]*x[38];
  xdot[40] = w[4]-x[4]+p[3]*x[39]*2.0-p[3]*x[40];
  xdot[41] = x[4]-x[5]+p[3]*x[40]-p[3]*x[41];
  xdot[42] = x[5]-x[6]+p[3]*x[41]-p[3]*x[42];
  xdot[43] = x[6]-x[7]+p[3]*x[42]-p[3]*x[43];
  xdot[44] = x[7]-x[8]+p[3]*x[43]-p[3]*x[44];
  xdot[45] = -p[0]*w[0]*x[45]+k[1]*p[3]*w[2]*x[53];
  xdot[46] = p[0]*w[0]*x[45]-p[1]*x[1]*x[46]*4.0;
  xdot[47] = -p[2]*x[47]+p[1]*x[1]*x[46]*2.0;
  xdot[48] = -p[3]*x[48]+k[0]*p[2]*w[3]*x[47];
  xdot[49] = p[3]*x[48]*2.0-p[3]*x[49];
  xdot[50] = p[3]*x[49]-p[3]*x[50];
  xdot[51] = p[3]*x[50]-p[3]*x[51];
  xdot[52] = p[3]*x[51]-p[3]*x[52];
  xdot[53] = p[3]*x[52]-p[3]*x[53];
  xdot[54] = -p[0]*x[0]*w[5]-p[0]*w[0]*x[54]+k[1]*p[3]*w[2]*x[62];
  xdot[55] = p[0]*x[0]*w[5]+p[0]*w[0]*x[54]-p[1]*x[1]*x[55]*4.0;
  xdot[56] = -p[2]*x[56]+p[1]*x[1]*x[55]*2.0;
  xdot[57] = -p[3]*x[57]+k[0]*p[2]*w[3]*x[56];
  xdot[58] = p[3]*x[57]*2.0-p[3]*x[58];
  xdot[59] = p[3]*x[58]-p[3]*x[59];
  xdot[60] = p[3]*x[59]-p[3]*x[60];
  xdot[61] = p[3]*x[60]-p[3]*x[61];
  xdot[62] = p[3]*x[61]-p[3]*x[62];
  xdot[63] = -p[0]*x[0]*w[6]-p[0]*w[0]*x[63]+k[1]*p[3]*w[2]*x[71];
  xdot[64] = p[0]*x[0]*w[6]+p[0]*w[0]*x[63]-p[1]*x[1]*x[64]*4.0;
  xdot[65] = -p[2]*x[65]+p[1]*x[1]*x[64]*2.0;
  xdot[66] = -p[3]*x[66]+k[0]*p[2]*w[3]*x[65];
  xdot[67] = p[3]*x[66]*2.0-p[3]*x[67];
  xdot[68] = p[3]*x[67]-p[3]*x[68];
  xdot[69] = p[3]*x[68]-p[3]*x[69];
  xdot[70] = p[3]*x[69]-p[3]*x[70];
  xdot[71] = p[3]*x[70]-p[3]*x[71];
  xdot[72] = -p[0]*x[0]*w[7]-p[0]*w[0]*x[72]+k[1]*p[3]*w[2]*x[80];
  xdot[73] = p[0]*x[0]*w[7]+p[0]*w[0]*x[72]-p[1]*x[1]*x[73]*4.0;
  xdot[74] = -p[2]*x[74]+p[1]*x[1]*x[73]*2.0;
  xdot[75] = -p[3]*x[75]+k[0]*p[2]*w[3]*x[74];
  xdot[76] = p[3]*x[75]*2.0-p[3]*x[76];
  xdot[77] = p[3]*x[76]-p[3]*x[77];
  xdot[78] = p[3]*x[77]-p[3]*x[78];
  xdot[79] = p[3]*x[78]-p[3]*x[79];
  xdot[80] = p[3]*x[79]-p[3]*x[80];
  xdot[81] = -p[0]*x[0]*w[8]-p[0]*w[0]*x[81]+k[1]*p[3]*w[2]*x[89];
  xdot[82] = p[0]*x[0]*w[8]+p[0]*w[0]*x[81]-p[1]*x[1]*x[82]*4.0;
  xdot[83] = -p[2]*x[83]+p[1]*x[1]*x[82]*2.0;
  xdot[84] = -p[3]*x[84]+k[0]*p[2]*w[3]*x[83];
  xdot[85] = p[3]*x[84]*2.0-p[3]*x[85];
  xdot[86] = p[3]*x[85]-p[3]*x[86];
  xdot[87] = p[3]*x[86]-p[3]*x[87];
  xdot[88] = p[3]*x[87]-p[3]*x[88];
  xdot[89] = p[3]*x[88]-p[3]*x[89];
  xdot[90] = -p[0]*x[0]*w[9]-p[0]*w[0]*x[90]+k[1]*p[3]*w[2]*x[98];
  xdot[91] = p[0]*x[0]*w[9]+p[0]*w[0]*x[90]-p[1]*x[1]*x[91]*4.0;
  xdot[92] = -p[2]*x[92]+p[1]*x[1]*x[91]*2.0;
  xdot[93] = -p[3]*x[93]+k[0]*p[2]*w[3]*x[92];
  xdot[94] = p[3]*x[93]*2.0-p[3]*x[94];
  xdot[95] = p[3]*x[94]-p[3]*x[95];
  xdot[96] = p[3]*x[95]-p[3]*x[96];
  xdot[97] = p[3]*x[96]-p[3]*x[97];
  xdot[98] = p[3]*x[97]-p[3]*x[98];
  xdot[99] = -p[0]*w[0]*x[99]+k[1]*p[3]*w[2]*x[107];
  xdot[100] = p[0]*w[0]*x[99]-p[1]*x[1]*x[100]*4.0;
  xdot[101] = -p[2]*x[101]+p[1]*x[1]*x[100]*2.0;
  xdot[102] = -p[3]*x[102]+k[0]*p[2]*w[3]*x[101];
  xdot[103] = p[3]*x[102]*2.0-p[3]*x[103];
  xdot[104] = p[3]*x[103]-p[3]*x[104];
  xdot[105] = p[3]*x[104]-p[3]*x[105];
  xdot[106] = p[3]*x[105]-p[3]*x[106];
  xdot[107] = p[3]*x[106]-p[3]*x[107];
  xdot[108] = -p[0]*w[0]*x[108]+k[1]*p[3]*w[2]*x[116];
  xdot[109] = p[0]*w[0]*x[108]-p[1]*x[1]*x[109]*4.0;
  xdot[110] = -p[2]*x[110]+p[1]*x[1]*x[109]*2.0;
  xdot[111] = -p[3]*x[111]+k[0]*p[2]*w[3]*x[110];
  xdot[112] = p[3]*x[111]*2.0-p[3]*x[112];
  xdot[113] = p[3]*x[112]-p[3]*x[113];
  xdot[114] = p[3]*x[113]-p[3]*x[114];
  xdot[115] = p[3]*x[114]-p[3]*x[115];
  xdot[116] = p[3]*x[115]-p[3]*x[116];
  xdot[117] = -p[0]*w[0]*x[117]+k[1]*p[3]*w[2]*x[125];
  xdot[118] = p[0]*w[0]*x[117]-p[1]*x[1]*x[118]*4.0;
  xdot[119] = -p[2]*x[119]+p[1]*x[1]*x[118]*2.0;
  xdot[120] = -p[3]*x[120]+k[0]*p[2]*w[3]*x[119];
  xdot[121] = p[3]*x[120]*2.0-p[3]*x[121];
  xdot[122] = p[3]*x[121]-p[3]*x[122];
  xdot[123] = p[3]*x[122]-p[3]*x[123];
  xdot[124] = p[3]*x[123]-p[3]*x[124];
  xdot[125] = p[3]*x[124]-p[3]*x[125];
  xdot[126] = -p[0]*w[0]*x[126]+k[1]*p[3]*w[2]*x[134];
  xdot[127] = p[0]*w[0]*x[126]-p[1]*x[1]*x[127]*4.0;
  xdot[128] = -p[2]*x[128]+p[1]*x[1]*x[127]*2.0;
  xdot[129] = -p[3]*x[129]+k[0]*p[2]*w[3]*x[128];
  xdot[130] = p[3]*x[129]*2.0-p[3]*x[130];
  xdot[131] = p[3]*x[130]-p[3]*x[131];
  xdot[132] = p[3]*x[131]-p[3]*x[132];
  xdot[133] = p[3]*x[132]-p[3]*x[133];
  xdot[134] = p[3]*x[133]-p[3]*x[134];
  xdot[135] = -p[0]*w[0]*x[135]+k[1]*p[3]*w[2]*x[143];
  xdot[136] = p[0]*w[0]*x[135]-p[1]*x[1]*x[136]*4.0;
  xdot[137] = -p[2]*x[137]+p[1]*x[1]*x[136]*2.0;
  xdot[138] = -p[3]*x[138]+k[0]*p[2]*w[3]*x[137];
  xdot[139] = p[3]*x[138]*2.0-p[3]*x[139];
  xdot[140] = p[3]*x[139]-p[3]*x[140];
  xdot[141] = p[3]*x[140]-p[3]*x[141];
  xdot[142] = p[3]*x[141]-p[3]*x[142];
  xdot[143] = p[3]*x[142]-p[3]*x[143];
  xdot[144] = -p[0]*w[0]*x[144]+k[1]*p[3]*w[2]*x[152];
  xdot[145] = p[0]*w[0]*x[144]-p[1]*x[1]*x[145]*4.0;
  xdot[146] = -p[2]*x[146]+p[1]*x[1]*x[145]*2.0;
  xdot[147] = -p[3]*x[147]+k[0]*p[2]*w[3]*x[146];
  xdot[148] = p[3]*x[147]*2.0-p[3]*x[148];
  xdot[149] = p[3]*x[148]-p[3]*x[149];
  xdot[150] = p[3]*x[149]-p[3]*x[150];
  xdot[151] = p[3]*x[150]-p[3]*x[151];
  xdot[152] = p[3]*x[151]-p[3]*x[152];
  xdot[153] = -p[0]*w[0]*x[153]+k[1]*p[3]*w[2]*x[161];
  xdot[154] = p[0]*w[0]*x[153]-p[1]*x[1]*x[154]*4.0;
  xdot[155] = -p[2]*x[155]+p[1]*x[1]*x[154]*2.0;
  xdot[156] = -p[3]*x[156]+k[0]*p[2]*w[3]*x[155];
  xdot[157] = p[3]*x[156]*2.0-p[3]*x[157];
  xdot[158] = p[3]*x[157]-p[3]*x[158];
  xdot[159] = p[3]*x[158]-p[3]*x[159];
  xdot[160] = p[3]*x[159]-p[3]*x[160];
  xdot[161] = p[3]*x[160]-p[3]*x[161];
}

