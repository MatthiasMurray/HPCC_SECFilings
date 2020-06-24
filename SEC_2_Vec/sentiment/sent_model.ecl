IMPORT * FROM SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment as s;
IMPORT * FROM s;
IMPORT TextVectors as tv;
IMPORT tv.Types AS Types;
IMPORT * FROM Types;
IMPORT * FROM ML_Core;
IMPORT ML_Core.Types as mlTypes;
IMPORT ML_Core.Interfaces;
IMPORT * FROM LogisticRegression;

Sentence := tv.Types.Sentence;
TextMod := tv.Types.TextMod;

EXPORT sent_model := MODULE

    EXPORT trainrec := RECORD
        tv.Types.t_TextId id;
        tv.Types.t_Sentence text;
        tv.Types.t_Vector vec;
        STRING label;
    END;

    EXPORT trndata_wlbl (STRING path,BOOLEAN labelnames=TRUE,STRING comparedto='plain') := FUNCTION
    //EXPORT trndata_wlbl (STRING path,BOOLEAN labelnames=TRUE,STRING approach='vanilla') := FUNCTION

        rawsents := secvec_input_lbl(path,labelnames,comparedto);
        
        rawrec := RECORD
            UNSIGNED8 sentId := rawsents.sentId;
            STRING text := rawsents.text;
        END;
        outlblrec := RECORD
            UNSIGNED8 sentId := rawsents.sentId;
            //STRING text := rawsents.text;
            STRING label := rawsents.label;
        END;
        jrec := RECORD(TextMod)
            STRING label;
        END;

        trainSentences := TABLE(rawsents,rawrec);
        labelSentences := TABLE(rawsents,outlblrec);

        sv := tv.SentenceVectors();
        model := sv.GetModel(trainSentences);
        //ssn := sent_setup_norm(path);
        ssn := sent_setup_norm(trainSentences,model);
        vanstart := model(typ=2);
        vanrec := RECORD
            UNSIGNED8 sentId := vanstart.id;
            STRING text := vanstart.text;
            tv.Types.t_Vector vec := vanstart.vec;
        END;
        vands := TABLE(vanstart,vanrec);
        tfidfstart := ssn.sembed_grp_experimental;
        tfhelprec := RECORD
            UNSIGNED8 sentId := tfidfstart.sentId;
            STRING text := tfidfstart.text;
            tv.Types.t_Vector vec := tfidfstart.w_Vector;
        END;
        tfds := TABLE(tfidfstart,tfhelprec);
        //sentmod := IF(approach='vanilla',vands,tfds);

        smodrec := RECORD
            UNSIGNED8 sentId;
            STRING text;
            tv.Types.t_Vector vec;
        END;

        trainrec lrT(smodrec s,DATASET(outlblrec) r) := TRANSFORM
            SELF.id := s.sentId;
            SELF.text := s.text;
            SELF.vec := s.vec;
            SELF.label := r(sentId = s.sentId)[1].label;
        END;

        //out := PROJECT(sentmod,lrT(LEFT,labelSentences));
        vanout := PROJECT(vands,lrT(LEFT,labelSentences));
        tfout  := PROJECT(tfds,lrT(LEFT,labelSentences));

        //RETURN out;
        RETURN [vanout,tfout];
    END;
    
    EXPORT numval := RECORD
        UNSIGNED4 number;
        REAL8 value;
    END;

    EXPORT numval tvec_to_numval(tv.Types.t_Vector vv) := FUNCTION

        invec:=DATASET(vv,{REAL8 value});

            
        midrec := RECORD
            UNSIGNED4 one;
            UNSIGNED4 number;
            REAL8 value;
        END;
        midrec midT(RECORDOF(invec) v) := TRANSFORM
            SELF.one := 1;
            SELF.number := 0;
            SELF.value := v.value;
        END;
        mid1 := PROJECT(invec,midT(LEFT));
        midrec consec(midrec L,midrec R) := TRANSFORM
            SELF.number := L.number + R.one;
            SELF := R;
        END;
        mid2 := ITERATE(mid1,consec(LEFT,RIGHT));
        outrec := RECORD
            UNSIGNED4 number;
            REAL8 value;
        END;
        outrec outT(midrec m2) := TRANSFORM
            SELF.number := m2.number;
            SELF.value := m2.value;
        END;
        out := PROJECT(mid2,outT(LEFT));
        RETURN out;
    END;

    EXPORT nf_firstrec := RECORD
        UNSIGNED2 wi;
        UNSIGNED8 id;
        DATASET(numval) numvals;
    END;

    EXPORT getFields(DATASET(trainrec) tr) := FUNCTION
    //EXPORT getNumericField(DATASET(trainrec) tr) := FUNCTION
        vecrec := RECORD
            REAL8 value;
        END;

        // vecdsrec := RECORD
        //     UNSIGNED rowid;
        //     DATASET(vecrec) vecds;
        // END;
        fldrec := RECORD
            UNSIGNED rowid;
            DATASET(vecrec) vecds;
            INTEGER4 label;
        END;

        // vecdsrec todsT(trainrec d, INTEGER C) := TRANSFORM
        //     SELF.rowid := C;
        //     SELF.vecds := DATASET(d.vec,vecrec);
        // END;

        fldrec fldT(trainrec d,INTEGER C) := TRANSFORM
            SELF.rowid := C;
            SELF.vecds := DATASET(d.vec,vecrec);
            SELF.label := (INTEGER4) d.label;
        END;

        //vec_as_ds := PROJECT(tr,todsT(LEFT,COUNTER));

        vec_as_ds := PROJECT(tr,fldT(LEFT,COUNTER));

        //FIXME: Currently written out explicitly
        //Consider applying MACRO
        //Turns out these are 800 dimensional not 100 dimensional
        nastyrec := RECORD
            UNSIGNED id;REAL8 val1;REAL8 val2;REAL8 val3;REAL8 val4;REAL8 val5;REAL8 val6;REAL8 val7;REAL8 val8;REAL8 val9;REAL8 val10;REAL8 val11;REAL8 val12;REAL8 val13;REAL8 val14;REAL8 val15;REAL8 val16;REAL8 val17;REAL8 val18;REAL8 val19;REAL8 val20;REAL8 val21;REAL8 val22;REAL8 val23;REAL8 val24;REAL8 val25;REAL8 val26;REAL8 val27;REAL8 val28;REAL8 val29;REAL8 val30;REAL8 val31;REAL8 val32;REAL8 val33;REAL8 val34;REAL8 val35;REAL8 val36;REAL8 val37;REAL8 val38;REAL8 val39;REAL8 val40;REAL8 val41;REAL8 val42;REAL8 val43;REAL8 val44;REAL8 val45;REAL8 val46;REAL8 val47;REAL8 val48;REAL8 val49;REAL8 val50;REAL8 val51;REAL8 val52;REAL8 val53;REAL8 val54;REAL8 val55;REAL8 val56;REAL8 val57;REAL8 val58;REAL8 val59;REAL8 val60;REAL8 val61;REAL8 val62;REAL8 val63;REAL8 val64;REAL8 val65;REAL8 val66;REAL8 val67;REAL8 val68;REAL8 val69;REAL8 val70;REAL8 val71;REAL8 val72;REAL8 val73;REAL8 val74;REAL8 val75;REAL8 val76;REAL8 val77;REAL8 val78;REAL8 val79;REAL8 val80;REAL8 val81;REAL8 val82;REAL8 val83;REAL8 val84;REAL8 val85;REAL8 val86;REAL8 val87;REAL8 val88;REAL8 val89;REAL8 val90;REAL8 val91;REAL8 val92;REAL8 val93;REAL8 val94;REAL8 val95;REAL8 val96;REAL8 val97;REAL8 val98;REAL8 val99;REAL8 val100;
            INTEGER4 label;
        END;
        //nastyrec := RECORD
        //UNSIGNED id;REAL8 val1;REAL8 val2;REAL8 val3;REAL8 val4;REAL8 val5;REAL8 val6;REAL8 val7;REAL8 val8;REAL8 val9;REAL8 val10;REAL8 val11;REAL8 val12;REAL8 val13;REAL8 val14;REAL8 val15;REAL8 val16;REAL8 val17;REAL8 val18;REAL8 val19;REAL8 val20;REAL8 val21;REAL8 val22;REAL8 val23;REAL8 val24;REAL8 val25;REAL8 val26;REAL8 val27;REAL8 val28;REAL8 val29;REAL8 val30;REAL8 val31;REAL8 val32;REAL8 val33;REAL8 val34;REAL8 val35;REAL8 val36;REAL8 val37;REAL8 val38;REAL8 val39;REAL8 val40;REAL8 val41;REAL8 val42;REAL8 val43;REAL8 val44;REAL8 val45;REAL8 val46;REAL8 val47;REAL8 val48;REAL8 val49;REAL8 val50;REAL8 val51;REAL8 val52;REAL8 val53;REAL8 val54;REAL8 val55;REAL8 val56;REAL8 val57;REAL8 val58;REAL8 val59;REAL8 val60;REAL8 val61;REAL8 val62;REAL8 val63;REAL8 val64;REAL8 val65;REAL8 val66;REAL8 val67;REAL8 val68;REAL8 val69;REAL8 val70;REAL8 val71;REAL8 val72;REAL8 val73;REAL8 val74;REAL8 val75;REAL8 val76;REAL8 val77;REAL8 val78;REAL8 val79;REAL8 val80;REAL8 val81;REAL8 val82;REAL8 val83;REAL8 val84;REAL8 val85;REAL8 val86;REAL8 val87;REAL8 val88;REAL8 val89;REAL8 val90;REAL8 val91;REAL8 val92;REAL8 val93;REAL8 val94;REAL8 val95;REAL8 val96;REAL8 val97;REAL8 val98;REAL8 val99;REAL8 val100;REAL8 val101;REAL8 val102;REAL8 val103;REAL8 val104;REAL8 val105;REAL8 val106;REAL8 val107;REAL8 val108;REAL8 val109;REAL8 val110;REAL8 val111;REAL8 val112;REAL8 val113;REAL8 val114;REAL8 val115;REAL8 val116;REAL8 val117;REAL8 val118;REAL8 val119;REAL8 val120;REAL8 val121;REAL8 val122;REAL8 val123;REAL8 val124;REAL8 val125;REAL8 val126;REAL8 val127;REAL8 val128;REAL8 val129;REAL8 val130;REAL8 val131;REAL8 val132;REAL8 val133;REAL8 val134;REAL8 val135;REAL8 val136;REAL8 val137;REAL8 val138;REAL8 val139;REAL8 val140;REAL8 val141;REAL8 val142;REAL8 val143;REAL8 val144;REAL8 val145;REAL8 val146;REAL8 val147;REAL8 val148;REAL8 val149;REAL8 val150;REAL8 val151;REAL8 val152;REAL8 val153;REAL8 val154;REAL8 val155;REAL8 val156;REAL8 val157;REAL8 val158;REAL8 val159;REAL8 val160;REAL8 val161;REAL8 val162;REAL8 val163;REAL8 val164;REAL8 val165;REAL8 val166;REAL8 val167;REAL8 val168;REAL8 val169;REAL8 val170;REAL8 val171;REAL8 val172;REAL8 val173;REAL8 val174;REAL8 val175;REAL8 val176;REAL8 val177;REAL8 val178;REAL8 val179;REAL8 val180;REAL8 val181;REAL8 val182;REAL8 val183;REAL8 val184;REAL8 val185;REAL8 val186;REAL8 val187;REAL8 val188;REAL8 val189;REAL8 val190;REAL8 val191;REAL8 val192;REAL8 val193;REAL8 val194;REAL8 val195;REAL8 val196;REAL8 val197;REAL8 val198;REAL8 val199;REAL8 val200;REAL8 val201;REAL8 val202;REAL8 val203;REAL8 val204;REAL8 val205;REAL8 val206;REAL8 val207;REAL8 val208;REAL8 val209;REAL8 val210;REAL8 val211;REAL8 val212;REAL8 val213;REAL8 val214;REAL8 val215;REAL8 val216;REAL8 val217;REAL8 val218;REAL8 val219;REAL8 val220;REAL8 val221;REAL8 val222;REAL8 val223;REAL8 val224;REAL8 val225;REAL8 val226;REAL8 val227;REAL8 val228;REAL8 val229;REAL8 val230;REAL8 val231;REAL8 val232;REAL8 val233;REAL8 val234;REAL8 val235;REAL8 val236;REAL8 val237;REAL8 val238;REAL8 val239;REAL8 val240;REAL8 val241;REAL8 val242;REAL8 val243;REAL8 val244;REAL8 val245;REAL8 val246;REAL8 val247;REAL8 val248;REAL8 val249;REAL8 val250;REAL8 val251;REAL8 val252;REAL8 val253;REAL8 val254;REAL8 val255;REAL8 val256;REAL8 val257;REAL8 val258;REAL8 val259;REAL8 val260;REAL8 val261;REAL8 val262;REAL8 val263;REAL8 val264;REAL8 val265;REAL8 val266;REAL8 val267;REAL8 val268;REAL8 val269;REAL8 val270;REAL8 val271;REAL8 val272;REAL8 val273;REAL8 val274;REAL8 val275;REAL8 val276;REAL8 val277;REAL8 val278;REAL8 val279;REAL8 val280;REAL8 val281;REAL8 val282;REAL8 val283;REAL8 val284;REAL8 val285;REAL8 val286;REAL8 val287;REAL8 val288;REAL8 val289;REAL8 val290;REAL8 val291;REAL8 val292;REAL8 val293;REAL8 val294;REAL8 val295;REAL8 val296;REAL8 val297;REAL8 val298;REAL8 val299;REAL8 val300;REAL8 val301;REAL8 val302;REAL8 val303;REAL8 val304;REAL8 val305;REAL8 val306;REAL8 val307;REAL8 val308;REAL8 val309;REAL8 val310;REAL8 val311;REAL8 val312;REAL8 val313;REAL8 val314;REAL8 val315;REAL8 val316;REAL8 val317;REAL8 val318;REAL8 val319;REAL8 val320;REAL8 val321;REAL8 val322;REAL8 val323;REAL8 val324;REAL8 val325;REAL8 val326;REAL8 val327;REAL8 val328;REAL8 val329;REAL8 val330;REAL8 val331;REAL8 val332;REAL8 val333;REAL8 val334;REAL8 val335;REAL8 val336;REAL8 val337;REAL8 val338;REAL8 val339;REAL8 val340;REAL8 val341;REAL8 val342;REAL8 val343;REAL8 val344;REAL8 val345;REAL8 val346;REAL8 val347;REAL8 val348;REAL8 val349;REAL8 val350;REAL8 val351;REAL8 val352;REAL8 val353;REAL8 val354;REAL8 val355;REAL8 val356;REAL8 val357;REAL8 val358;REAL8 val359;REAL8 val360;REAL8 val361;REAL8 val362;REAL8 val363;REAL8 val364;REAL8 val365;REAL8 val366;REAL8 val367;REAL8 val368;REAL8 val369;REAL8 val370;REAL8 val371;REAL8 val372;REAL8 val373;REAL8 val374;REAL8 val375;REAL8 val376;REAL8 val377;REAL8 val378;REAL8 val379;REAL8 val380;REAL8 val381;REAL8 val382;REAL8 val383;REAL8 val384;REAL8 val385;REAL8 val386;REAL8 val387;REAL8 val388;REAL8 val389;REAL8 val390;REAL8 val391;REAL8 val392;REAL8 val393;REAL8 val394;REAL8 val395;REAL8 val396;REAL8 val397;REAL8 val398;REAL8 val399;REAL8 val400;REAL8 val401;REAL8 val402;REAL8 val403;REAL8 val404;REAL8 val405;REAL8 val406;REAL8 val407;REAL8 val408;REAL8 val409;REAL8 val410;REAL8 val411;REAL8 val412;REAL8 val413;REAL8 val414;REAL8 val415;REAL8 val416;REAL8 val417;REAL8 val418;REAL8 val419;REAL8 val420;REAL8 val421;REAL8 val422;REAL8 val423;REAL8 val424;REAL8 val425;REAL8 val426;REAL8 val427;REAL8 val428;REAL8 val429;REAL8 val430;REAL8 val431;REAL8 val432;REAL8 val433;REAL8 val434;REAL8 val435;REAL8 val436;REAL8 val437;REAL8 val438;REAL8 val439;REAL8 val440;REAL8 val441;REAL8 val442;REAL8 val443;REAL8 val444;REAL8 val445;REAL8 val446;REAL8 val447;REAL8 val448;REAL8 val449;REAL8 val450;REAL8 val451;REAL8 val452;REAL8 val453;REAL8 val454;REAL8 val455;REAL8 val456;REAL8 val457;REAL8 val458;REAL8 val459;REAL8 val460;REAL8 val461;REAL8 val462;REAL8 val463;REAL8 val464;REAL8 val465;REAL8 val466;REAL8 val467;REAL8 val468;REAL8 val469;REAL8 val470;REAL8 val471;REAL8 val472;REAL8 val473;REAL8 val474;REAL8 val475;REAL8 val476;REAL8 val477;REAL8 val478;REAL8 val479;REAL8 val480;REAL8 val481;REAL8 val482;REAL8 val483;REAL8 val484;REAL8 val485;REAL8 val486;REAL8 val487;REAL8 val488;REAL8 val489;REAL8 val490;REAL8 val491;REAL8 val492;REAL8 val493;REAL8 val494;REAL8 val495;REAL8 val496;REAL8 val497;REAL8 val498;REAL8 val499;REAL8 val500;REAL8 val501;REAL8 val502;REAL8 val503;REAL8 val504;REAL8 val505;REAL8 val506;REAL8 val507;REAL8 val508;REAL8 val509;REAL8 val510;REAL8 val511;REAL8 val512;REAL8 val513;REAL8 val514;REAL8 val515;REAL8 val516;REAL8 val517;REAL8 val518;REAL8 val519;REAL8 val520;REAL8 val521;REAL8 val522;REAL8 val523;REAL8 val524;REAL8 val525;REAL8 val526;REAL8 val527;REAL8 val528;REAL8 val529;REAL8 val530;REAL8 val531;REAL8 val532;REAL8 val533;REAL8 val534;REAL8 val535;REAL8 val536;REAL8 val537;REAL8 val538;REAL8 val539;REAL8 val540;REAL8 val541;REAL8 val542;REAL8 val543;REAL8 val544;REAL8 val545;REAL8 val546;REAL8 val547;REAL8 val548;REAL8 val549;REAL8 val550;REAL8 val551;REAL8 val552;REAL8 val553;REAL8 val554;REAL8 val555;REAL8 val556;REAL8 val557;REAL8 val558;REAL8 val559;REAL8 val560;REAL8 val561;REAL8 val562;REAL8 val563;REAL8 val564;REAL8 val565;REAL8 val566;REAL8 val567;REAL8 val568;REAL8 val569;REAL8 val570;REAL8 val571;REAL8 val572;REAL8 val573;REAL8 val574;REAL8 val575;REAL8 val576;REAL8 val577;REAL8 val578;REAL8 val579;REAL8 val580;REAL8 val581;REAL8 val582;REAL8 val583;REAL8 val584;REAL8 val585;REAL8 val586;REAL8 val587;REAL8 val588;REAL8 val589;REAL8 val590;REAL8 val591;REAL8 val592;REAL8 val593;REAL8 val594;REAL8 val595;REAL8 val596;REAL8 val597;REAL8 val598;REAL8 val599;REAL8 val600;REAL8 val601;REAL8 val602;REAL8 val603;REAL8 val604;REAL8 val605;REAL8 val606;REAL8 val607;REAL8 val608;REAL8 val609;REAL8 val610;REAL8 val611;REAL8 val612;REAL8 val613;REAL8 val614;REAL8 val615;REAL8 val616;REAL8 val617;REAL8 val618;REAL8 val619;REAL8 val620;REAL8 val621;REAL8 val622;REAL8 val623;REAL8 val624;REAL8 val625;REAL8 val626;REAL8 val627;REAL8 val628;REAL8 val629;REAL8 val630;REAL8 val631;REAL8 val632;REAL8 val633;REAL8 val634;REAL8 val635;REAL8 val636;REAL8 val637;REAL8 val638;REAL8 val639;REAL8 val640;REAL8 val641;REAL8 val642;REAL8 val643;REAL8 val644;REAL8 val645;REAL8 val646;REAL8 val647;REAL8 val648;REAL8 val649;REAL8 val650;REAL8 val651;REAL8 val652;REAL8 val653;REAL8 val654;REAL8 val655;REAL8 val656;REAL8 val657;REAL8 val658;REAL8 val659;REAL8 val660;REAL8 val661;REAL8 val662;REAL8 val663;REAL8 val664;REAL8 val665;REAL8 val666;REAL8 val667;REAL8 val668;REAL8 val669;REAL8 val670;REAL8 val671;REAL8 val672;REAL8 val673;REAL8 val674;REAL8 val675;REAL8 val676;REAL8 val677;REAL8 val678;REAL8 val679;REAL8 val680;REAL8 val681;REAL8 val682;REAL8 val683;REAL8 val684;REAL8 val685;REAL8 val686;REAL8 val687;REAL8 val688;REAL8 val689;REAL8 val690;REAL8 val691;REAL8 val692;REAL8 val693;REAL8 val694;REAL8 val695;REAL8 val696;REAL8 val697;REAL8 val698;REAL8 val699;REAL8 val700;REAL8 val701;REAL8 val702;REAL8 val703;REAL8 val704;REAL8 val705;REAL8 val706;REAL8 val707;REAL8 val708;REAL8 val709;REAL8 val710;REAL8 val711;REAL8 val712;REAL8 val713;REAL8 val714;REAL8 val715;REAL8 val716;REAL8 val717;REAL8 val718;REAL8 val719;REAL8 val720;REAL8 val721;REAL8 val722;REAL8 val723;REAL8 val724;REAL8 val725;REAL8 val726;REAL8 val727;REAL8 val728;REAL8 val729;REAL8 val730;REAL8 val731;REAL8 val732;REAL8 val733;REAL8 val734;REAL8 val735;REAL8 val736;REAL8 val737;REAL8 val738;REAL8 val739;REAL8 val740;REAL8 val741;REAL8 val742;REAL8 val743;REAL8 val744;REAL8 val745;REAL8 val746;REAL8 val747;REAL8 val748;REAL8 val749;REAL8 val750;REAL8 val751;REAL8 val752;REAL8 val753;REAL8 val754;REAL8 val755;REAL8 val756;REAL8 val757;REAL8 val758;REAL8 val759;REAL8 val760;REAL8 val761;REAL8 val762;REAL8 val763;REAL8 val764;REAL8 val765;REAL8 val766;REAL8 val767;REAL8 val768;REAL8 val769;REAL8 val770;REAL8 val771;REAL8 val772;REAL8 val773;REAL8 val774;REAL8 val775;REAL8 val776;REAL8 val777;REAL8 val778;REAL8 val779;REAL8 val780;REAL8 val781;REAL8 val782;REAL8 val783;REAL8 val784;REAL8 val785;REAL8 val786;REAL8 val787;REAL8 val788;REAL8 val789;REAL8 val790;REAL8 val791;REAL8 val792;REAL8 val793;REAL8 val794;REAL8 val795;REAL8 val796;REAL8 val797;REAL8 val798;REAL8 val799;REAL8 val800;
        //END;

        //nastyrec nastyT(vecdsrec vr) := TRANSFORM
        nastyrec nastyT(fldrec vr) := TRANSFORM
            SELF.id := vr.rowid;SELF.val1:=vr.vecds[1].value;SELF.val2:=vr.vecds[2].value;SELF.val3:=vr.vecds[3].value;SELF.val4:=vr.vecds[4].value;SELF.val5:=vr.vecds[5].value;SELF.val6:=vr.vecds[6].value;SELF.val7:=vr.vecds[7].value;SELF.val8:=vr.vecds[8].value;SELF.val9:=vr.vecds[9].value;SELF.val10:=vr.vecds[10].value;SELF.val11:=vr.vecds[11].value;SELF.val12:=vr.vecds[12].value;SELF.val13:=vr.vecds[13].value;SELF.val14:=vr.vecds[14].value;SELF.val15:=vr.vecds[15].value;SELF.val16:=vr.vecds[16].value;SELF.val17:=vr.vecds[17].value;SELF.val18:=vr.vecds[18].value;SELF.val19:=vr.vecds[19].value;SELF.val20:=vr.vecds[20].value;SELF.val21:=vr.vecds[21].value;SELF.val22:=vr.vecds[22].value;SELF.val23:=vr.vecds[23].value;SELF.val24:=vr.vecds[24].value;SELF.val25:=vr.vecds[25].value;SELF.val26:=vr.vecds[26].value;SELF.val27:=vr.vecds[27].value;SELF.val28:=vr.vecds[28].value;SELF.val29:=vr.vecds[29].value;SELF.val30:=vr.vecds[30].value;SELF.val31:=vr.vecds[31].value;SELF.val32:=vr.vecds[32].value;SELF.val33:=vr.vecds[33].value;SELF.val34:=vr.vecds[34].value;SELF.val35:=vr.vecds[35].value;SELF.val36:=vr.vecds[36].value;SELF.val37:=vr.vecds[37].value;SELF.val38:=vr.vecds[38].value;SELF.val39:=vr.vecds[39].value;SELF.val40:=vr.vecds[40].value;SELF.val41:=vr.vecds[41].value;SELF.val42:=vr.vecds[42].value;SELF.val43:=vr.vecds[43].value;SELF.val44:=vr.vecds[44].value;SELF.val45:=vr.vecds[45].value;SELF.val46:=vr.vecds[46].value;SELF.val47:=vr.vecds[47].value;SELF.val48:=vr.vecds[48].value;SELF.val49:=vr.vecds[49].value;SELF.val50:=vr.vecds[50].value;SELF.val51:=vr.vecds[51].value;SELF.val52:=vr.vecds[52].value;SELF.val53:=vr.vecds[53].value;SELF.val54:=vr.vecds[54].value;SELF.val55:=vr.vecds[55].value;SELF.val56:=vr.vecds[56].value;SELF.val57:=vr.vecds[57].value;SELF.val58:=vr.vecds[58].value;SELF.val59:=vr.vecds[59].value;SELF.val60:=vr.vecds[60].value;SELF.val61:=vr.vecds[61].value;SELF.val62:=vr.vecds[62].value;SELF.val63:=vr.vecds[63].value;SELF.val64:=vr.vecds[64].value;SELF.val65:=vr.vecds[65].value;SELF.val66:=vr.vecds[66].value;SELF.val67:=vr.vecds[67].value;SELF.val68:=vr.vecds[68].value;SELF.val69:=vr.vecds[69].value;SELF.val70:=vr.vecds[70].value;SELF.val71:=vr.vecds[71].value;SELF.val72:=vr.vecds[72].value;SELF.val73:=vr.vecds[73].value;SELF.val74:=vr.vecds[74].value;SELF.val75:=vr.vecds[75].value;SELF.val76:=vr.vecds[76].value;SELF.val77:=vr.vecds[77].value;SELF.val78:=vr.vecds[78].value;SELF.val79:=vr.vecds[79].value;SELF.val80:=vr.vecds[80].value;SELF.val81:=vr.vecds[81].value;SELF.val82:=vr.vecds[82].value;SELF.val83:=vr.vecds[83].value;SELF.val84:=vr.vecds[84].value;SELF.val85:=vr.vecds[85].value;SELF.val86:=vr.vecds[86].value;SELF.val87:=vr.vecds[87].value;SELF.val88:=vr.vecds[88].value;SELF.val89:=vr.vecds[89].value;SELF.val90:=vr.vecds[90].value;SELF.val91:=vr.vecds[91].value;SELF.val92:=vr.vecds[92].value;SELF.val93:=vr.vecds[93].value;SELF.val94:=vr.vecds[94].value;SELF.val95:=vr.vecds[95].value;SELF.val96:=vr.vecds[96].value;SELF.val97:=vr.vecds[97].value;SELF.val98:=vr.vecds[98].value;SELF.val99:=vr.vecds[99].value;SELF.val100:=vr.vecds[100].value;
            SELF.label := vr.label;
        END;
            //SELF.id := vr.rowid;
            // SELF.val1:=vr.vecds[1].value;SELF.val2:=vr.vecds[2].value;SELF.val3:=vr.vecds[3].value;SELF.val4:=vr.vecds[4].value;SELF.val5:=vr.vecds[5].value;SELF.val6:=vr.vecds[6].value;SELF.val7:=vr.vecds[7].value;SELF.val8:=vr.vecds[8].value;SELF.val9:=vr.vecds[9].value;SELF.val10:=vr.vecds[10].value;SELF.val11:=vr.vecds[11].value;SELF.val12:=vr.vecds[12].value;SELF.val13:=vr.vecds[13].value;SELF.val14:=vr.vecds[14].value;SELF.val15:=vr.vecds[15].value;SELF.val16:=vr.vecds[16].value;SELF.val17:=vr.vecds[17].value;SELF.val18:=vr.vecds[18].value;SELF.val19:=vr.vecds[19].value;SELF.val20:=vr.vecds[20].value;SELF.val21:=vr.vecds[21].value;SELF.val22:=vr.vecds[22].value;SELF.val23:=vr.vecds[23].value;SELF.val24:=vr.vecds[24].value;SELF.val25:=vr.vecds[25].value;SELF.val26:=vr.vecds[26].value;SELF.val27:=vr.vecds[27].value;SELF.val28:=vr.vecds[28].value;SELF.val29:=vr.vecds[29].value;SELF.val30:=vr.vecds[30].value;SELF.val31:=vr.vecds[31].value;SELF.val32:=vr.vecds[32].value;SELF.val33:=vr.vecds[33].value;SELF.val34:=vr.vecds[34].value;SELF.val35:=vr.vecds[35].value;SELF.val36:=vr.vecds[36].value;SELF.val37:=vr.vecds[37].value;SELF.val38:=vr.vecds[38].value;SELF.val39:=vr.vecds[39].value;SELF.val40:=vr.vecds[40].value;SELF.val41:=vr.vecds[41].value;SELF.val42:=vr.vecds[42].value;SELF.val43:=vr.vecds[43].value;SELF.val44:=vr.vecds[44].value;SELF.val45:=vr.vecds[45].value;SELF.val46:=vr.vecds[46].value;SELF.val47:=vr.vecds[47].value;SELF.val48:=vr.vecds[48].value;SELF.val49:=vr.vecds[49].value;SELF.val50:=vr.vecds[50].value;SELF.val51:=vr.vecds[51].value;SELF.val52:=vr.vecds[52].value;SELF.val53:=vr.vecds[53].value;SELF.val54:=vr.vecds[54].value;SELF.val55:=vr.vecds[55].value;SELF.val56:=vr.vecds[56].value;SELF.val57:=vr.vecds[57].value;SELF.val58:=vr.vecds[58].value;SELF.val59:=vr.vecds[59].value;SELF.val60:=vr.vecds[60].value;SELF.val61:=vr.vecds[61].value;SELF.val62:=vr.vecds[62].value;SELF.val63:=vr.vecds[63].value;SELF.val64:=vr.vecds[64].value;SELF.val65:=vr.vecds[65].value;SELF.val66:=vr.vecds[66].value;SELF.val67:=vr.vecds[67].value;SELF.val68:=vr.vecds[68].value;SELF.val69:=vr.vecds[69].value;SELF.val70:=vr.vecds[70].value;SELF.val71:=vr.vecds[71].value;SELF.val72:=vr.vecds[72].value;SELF.val73:=vr.vecds[73].value;SELF.val74:=vr.vecds[74].value;SELF.val75:=vr.vecds[75].value;SELF.val76:=vr.vecds[76].value;SELF.val77:=vr.vecds[77].value;SELF.val78:=vr.vecds[78].value;SELF.val79:=vr.vecds[79].value;SELF.val80:=vr.vecds[80].value;SELF.val81:=vr.vecds[81].value;SELF.val82:=vr.vecds[82].value;SELF.val83:=vr.vecds[83].value;SELF.val84:=vr.vecds[84].value;SELF.val85:=vr.vecds[85].value;SELF.val86:=vr.vecds[86].value;SELF.val87:=vr.vecds[87].value;SELF.val88:=vr.vecds[88].value;SELF.val89:=vr.vecds[89].value;SELF.val90:=vr.vecds[90].value;SELF.val91:=vr.vecds[91].value;SELF.val92:=vr.vecds[92].value;SELF.val93:=vr.vecds[93].value;SELF.val94:=vr.vecds[94].value;SELF.val95:=vr.vecds[95].value;SELF.val96:=vr.vecds[96].value;SELF.val97:=vr.vecds[97].value;SELF.val98:=vr.vecds[98].value;SELF.val99:=vr.vecds[99].value;SELF.val100:=vr.vecds[100].value;SELF.val101:=vr.vecds[101].value;SELF.val102:=vr.vecds[102].value;SELF.val103:=vr.vecds[103].value;SELF.val104:=vr.vecds[104].value;SELF.val105:=vr.vecds[105].value;SELF.val106:=vr.vecds[106].value;SELF.val107:=vr.vecds[107].value;SELF.val108:=vr.vecds[108].value;SELF.val109:=vr.vecds[109].value;SELF.val110:=vr.vecds[110].value;SELF.val111:=vr.vecds[111].value;SELF.val112:=vr.vecds[112].value;SELF.val113:=vr.vecds[113].value;SELF.val114:=vr.vecds[114].value;SELF.val115:=vr.vecds[115].value;SELF.val116:=vr.vecds[116].value;SELF.val117:=vr.vecds[117].value;SELF.val118:=vr.vecds[118].value;SELF.val119:=vr.vecds[119].value;SELF.val120:=vr.vecds[120].value;SELF.val121:=vr.vecds[121].value;SELF.val122:=vr.vecds[122].value;SELF.val123:=vr.vecds[123].value;SELF.val124:=vr.vecds[124].value;SELF.val125:=vr.vecds[125].value;SELF.val126:=vr.vecds[126].value;SELF.val127:=vr.vecds[127].value;SELF.val128:=vr.vecds[128].value;SELF.val129:=vr.vecds[129].value;SELF.val130:=vr.vecds[130].value;SELF.val131:=vr.vecds[131].value;SELF.val132:=vr.vecds[132].value;SELF.val133:=vr.vecds[133].value;SELF.val134:=vr.vecds[134].value;SELF.val135:=vr.vecds[135].value;SELF.val136:=vr.vecds[136].value;SELF.val137:=vr.vecds[137].value;SELF.val138:=vr.vecds[138].value;SELF.val139:=vr.vecds[139].value;SELF.val140:=vr.vecds[140].value;SELF.val141:=vr.vecds[141].value;SELF.val142:=vr.vecds[142].value;SELF.val143:=vr.vecds[143].value;SELF.val144:=vr.vecds[144].value;SELF.val145:=vr.vecds[145].value;SELF.val146:=vr.vecds[146].value;SELF.val147:=vr.vecds[147].value;SELF.val148:=vr.vecds[148].value;SELF.val149:=vr.vecds[149].value;SELF.val150:=vr.vecds[150].value;SELF.val151:=vr.vecds[151].value;SELF.val152:=vr.vecds[152].value;SELF.val153:=vr.vecds[153].value;SELF.val154:=vr.vecds[154].value;SELF.val155:=vr.vecds[155].value;SELF.val156:=vr.vecds[156].value;SELF.val157:=vr.vecds[157].value;SELF.val158:=vr.vecds[158].value;SELF.val159:=vr.vecds[159].value;SELF.val160:=vr.vecds[160].value;SELF.val161:=vr.vecds[161].value;SELF.val162:=vr.vecds[162].value;SELF.val163:=vr.vecds[163].value;SELF.val164:=vr.vecds[164].value;SELF.val165:=vr.vecds[165].value;SELF.val166:=vr.vecds[166].value;SELF.val167:=vr.vecds[167].value;SELF.val168:=vr.vecds[168].value;SELF.val169:=vr.vecds[169].value;SELF.val170:=vr.vecds[170].value;SELF.val171:=vr.vecds[171].value;SELF.val172:=vr.vecds[172].value;SELF.val173:=vr.vecds[173].value;SELF.val174:=vr.vecds[174].value;SELF.val175:=vr.vecds[175].value;SELF.val176:=vr.vecds[176].value;SELF.val177:=vr.vecds[177].value;SELF.val178:=vr.vecds[178].value;SELF.val179:=vr.vecds[179].value;SELF.val180:=vr.vecds[180].value;SELF.val181:=vr.vecds[181].value;SELF.val182:=vr.vecds[182].value;SELF.val183:=vr.vecds[183].value;SELF.val184:=vr.vecds[184].value;SELF.val185:=vr.vecds[185].value;SELF.val186:=vr.vecds[186].value;SELF.val187:=vr.vecds[187].value;SELF.val188:=vr.vecds[188].value;SELF.val189:=vr.vecds[189].value;SELF.val190:=vr.vecds[190].value;SELF.val191:=vr.vecds[191].value;SELF.val192:=vr.vecds[192].value;SELF.val193:=vr.vecds[193].value;SELF.val194:=vr.vecds[194].value;SELF.val195:=vr.vecds[195].value;SELF.val196:=vr.vecds[196].value;SELF.val197:=vr.vecds[197].value;SELF.val198:=vr.vecds[198].value;SELF.val199:=vr.vecds[199].value;SELF.val200:=vr.vecds[200].value;SELF.val201:=vr.vecds[201].value;SELF.val202:=vr.vecds[202].value;SELF.val203:=vr.vecds[203].value;SELF.val204:=vr.vecds[204].value;SELF.val205:=vr.vecds[205].value;SELF.val206:=vr.vecds[206].value;SELF.val207:=vr.vecds[207].value;SELF.val208:=vr.vecds[208].value;SELF.val209:=vr.vecds[209].value;SELF.val210:=vr.vecds[210].value;SELF.val211:=vr.vecds[211].value;SELF.val212:=vr.vecds[212].value;SELF.val213:=vr.vecds[213].value;SELF.val214:=vr.vecds[214].value;SELF.val215:=vr.vecds[215].value;SELF.val216:=vr.vecds[216].value;SELF.val217:=vr.vecds[217].value;SELF.val218:=vr.vecds[218].value;SELF.val219:=vr.vecds[219].value;SELF.val220:=vr.vecds[220].value;SELF.val221:=vr.vecds[221].value;SELF.val222:=vr.vecds[222].value;SELF.val223:=vr.vecds[223].value;SELF.val224:=vr.vecds[224].value;SELF.val225:=vr.vecds[225].value;SELF.val226:=vr.vecds[226].value;SELF.val227:=vr.vecds[227].value;SELF.val228:=vr.vecds[228].value;SELF.val229:=vr.vecds[229].value;SELF.val230:=vr.vecds[230].value;SELF.val231:=vr.vecds[231].value;SELF.val232:=vr.vecds[232].value;SELF.val233:=vr.vecds[233].value;SELF.val234:=vr.vecds[234].value;SELF.val235:=vr.vecds[235].value;SELF.val236:=vr.vecds[236].value;SELF.val237:=vr.vecds[237].value;SELF.val238:=vr.vecds[238].value;SELF.val239:=vr.vecds[239].value;SELF.val240:=vr.vecds[240].value;SELF.val241:=vr.vecds[241].value;SELF.val242:=vr.vecds[242].value;SELF.val243:=vr.vecds[243].value;SELF.val244:=vr.vecds[244].value;SELF.val245:=vr.vecds[245].value;SELF.val246:=vr.vecds[246].value;SELF.val247:=vr.vecds[247].value;SELF.val248:=vr.vecds[248].value;SELF.val249:=vr.vecds[249].value;SELF.val250:=vr.vecds[250].value;SELF.val251:=vr.vecds[251].value;SELF.val252:=vr.vecds[252].value;SELF.val253:=vr.vecds[253].value;SELF.val254:=vr.vecds[254].value;SELF.val255:=vr.vecds[255].value;SELF.val256:=vr.vecds[256].value;SELF.val257:=vr.vecds[257].value;SELF.val258:=vr.vecds[258].value;SELF.val259:=vr.vecds[259].value;SELF.val260:=vr.vecds[260].value;SELF.val261:=vr.vecds[261].value;SELF.val262:=vr.vecds[262].value;SELF.val263:=vr.vecds[263].value;SELF.val264:=vr.vecds[264].value;SELF.val265:=vr.vecds[265].value;SELF.val266:=vr.vecds[266].value;SELF.val267:=vr.vecds[267].value;SELF.val268:=vr.vecds[268].value;SELF.val269:=vr.vecds[269].value;SELF.val270:=vr.vecds[270].value;SELF.val271:=vr.vecds[271].value;SELF.val272:=vr.vecds[272].value;SELF.val273:=vr.vecds[273].value;SELF.val274:=vr.vecds[274].value;SELF.val275:=vr.vecds[275].value;SELF.val276:=vr.vecds[276].value;SELF.val277:=vr.vecds[277].value;SELF.val278:=vr.vecds[278].value;SELF.val279:=vr.vecds[279].value;SELF.val280:=vr.vecds[280].value;SELF.val281:=vr.vecds[281].value;SELF.val282:=vr.vecds[282].value;SELF.val283:=vr.vecds[283].value;SELF.val284:=vr.vecds[284].value;SELF.val285:=vr.vecds[285].value;SELF.val286:=vr.vecds[286].value;SELF.val287:=vr.vecds[287].value;SELF.val288:=vr.vecds[288].value;SELF.val289:=vr.vecds[289].value;SELF.val290:=vr.vecds[290].value;SELF.val291:=vr.vecds[291].value;SELF.val292:=vr.vecds[292].value;SELF.val293:=vr.vecds[293].value;SELF.val294:=vr.vecds[294].value;SELF.val295:=vr.vecds[295].value;SELF.val296:=vr.vecds[296].value;SELF.val297:=vr.vecds[297].value;SELF.val298:=vr.vecds[298].value;SELF.val299:=vr.vecds[299].value;SELF.val300:=vr.vecds[300].value;SELF.val301:=vr.vecds[301].value;SELF.val302:=vr.vecds[302].value;SELF.val303:=vr.vecds[303].value;SELF.val304:=vr.vecds[304].value;SELF.val305:=vr.vecds[305].value;SELF.val306:=vr.vecds[306].value;SELF.val307:=vr.vecds[307].value;SELF.val308:=vr.vecds[308].value;SELF.val309:=vr.vecds[309].value;SELF.val310:=vr.vecds[310].value;SELF.val311:=vr.vecds[311].value;SELF.val312:=vr.vecds[312].value;SELF.val313:=vr.vecds[313].value;SELF.val314:=vr.vecds[314].value;SELF.val315:=vr.vecds[315].value;SELF.val316:=vr.vecds[316].value;SELF.val317:=vr.vecds[317].value;SELF.val318:=vr.vecds[318].value;SELF.val319:=vr.vecds[319].value;SELF.val320:=vr.vecds[320].value;SELF.val321:=vr.vecds[321].value;SELF.val322:=vr.vecds[322].value;SELF.val323:=vr.vecds[323].value;SELF.val324:=vr.vecds[324].value;SELF.val325:=vr.vecds[325].value;SELF.val326:=vr.vecds[326].value;SELF.val327:=vr.vecds[327].value;SELF.val328:=vr.vecds[328].value;SELF.val329:=vr.vecds[329].value;SELF.val330:=vr.vecds[330].value;SELF.val331:=vr.vecds[331].value;SELF.val332:=vr.vecds[332].value;SELF.val333:=vr.vecds[333].value;SELF.val334:=vr.vecds[334].value;SELF.val335:=vr.vecds[335].value;SELF.val336:=vr.vecds[336].value;SELF.val337:=vr.vecds[337].value;SELF.val338:=vr.vecds[338].value;SELF.val339:=vr.vecds[339].value;SELF.val340:=vr.vecds[340].value;SELF.val341:=vr.vecds[341].value;SELF.val342:=vr.vecds[342].value;SELF.val343:=vr.vecds[343].value;SELF.val344:=vr.vecds[344].value;SELF.val345:=vr.vecds[345].value;SELF.val346:=vr.vecds[346].value;SELF.val347:=vr.vecds[347].value;SELF.val348:=vr.vecds[348].value;SELF.val349:=vr.vecds[349].value;SELF.val350:=vr.vecds[350].value;SELF.val351:=vr.vecds[351].value;SELF.val352:=vr.vecds[352].value;SELF.val353:=vr.vecds[353].value;SELF.val354:=vr.vecds[354].value;SELF.val355:=vr.vecds[355].value;SELF.val356:=vr.vecds[356].value;SELF.val357:=vr.vecds[357].value;SELF.val358:=vr.vecds[358].value;SELF.val359:=vr.vecds[359].value;SELF.val360:=vr.vecds[360].value;SELF.val361:=vr.vecds[361].value;SELF.val362:=vr.vecds[362].value;SELF.val363:=vr.vecds[363].value;SELF.val364:=vr.vecds[364].value;SELF.val365:=vr.vecds[365].value;SELF.val366:=vr.vecds[366].value;SELF.val367:=vr.vecds[367].value;SELF.val368:=vr.vecds[368].value;SELF.val369:=vr.vecds[369].value;SELF.val370:=vr.vecds[370].value;SELF.val371:=vr.vecds[371].value;SELF.val372:=vr.vecds[372].value;SELF.val373:=vr.vecds[373].value;SELF.val374:=vr.vecds[374].value;SELF.val375:=vr.vecds[375].value;SELF.val376:=vr.vecds[376].value;SELF.val377:=vr.vecds[377].value;SELF.val378:=vr.vecds[378].value;SELF.val379:=vr.vecds[379].value;SELF.val380:=vr.vecds[380].value;SELF.val381:=vr.vecds[381].value;SELF.val382:=vr.vecds[382].value;SELF.val383:=vr.vecds[383].value;SELF.val384:=vr.vecds[384].value;SELF.val385:=vr.vecds[385].value;SELF.val386:=vr.vecds[386].value;SELF.val387:=vr.vecds[387].value;SELF.val388:=vr.vecds[388].value;SELF.val389:=vr.vecds[389].value;SELF.val390:=vr.vecds[390].value;SELF.val391:=vr.vecds[391].value;SELF.val392:=vr.vecds[392].value;SELF.val393:=vr.vecds[393].value;SELF.val394:=vr.vecds[394].value;SELF.val395:=vr.vecds[395].value;SELF.val396:=vr.vecds[396].value;SELF.val397:=vr.vecds[397].value;SELF.val398:=vr.vecds[398].value;SELF.val399:=vr.vecds[399].value;SELF.val400:=vr.vecds[400].value;SELF.val401:=vr.vecds[401].value;SELF.val402:=vr.vecds[402].value;SELF.val403:=vr.vecds[403].value;SELF.val404:=vr.vecds[404].value;SELF.val405:=vr.vecds[405].value;SELF.val406:=vr.vecds[406].value;SELF.val407:=vr.vecds[407].value;SELF.val408:=vr.vecds[408].value;SELF.val409:=vr.vecds[409].value;SELF.val410:=vr.vecds[410].value;SELF.val411:=vr.vecds[411].value;SELF.val412:=vr.vecds[412].value;SELF.val413:=vr.vecds[413].value;SELF.val414:=vr.vecds[414].value;SELF.val415:=vr.vecds[415].value;SELF.val416:=vr.vecds[416].value;SELF.val417:=vr.vecds[417].value;SELF.val418:=vr.vecds[418].value;SELF.val419:=vr.vecds[419].value;SELF.val420:=vr.vecds[420].value;SELF.val421:=vr.vecds[421].value;SELF.val422:=vr.vecds[422].value;SELF.val423:=vr.vecds[423].value;SELF.val424:=vr.vecds[424].value;SELF.val425:=vr.vecds[425].value;SELF.val426:=vr.vecds[426].value;SELF.val427:=vr.vecds[427].value;SELF.val428:=vr.vecds[428].value;SELF.val429:=vr.vecds[429].value;SELF.val430:=vr.vecds[430].value;SELF.val431:=vr.vecds[431].value;SELF.val432:=vr.vecds[432].value;SELF.val433:=vr.vecds[433].value;SELF.val434:=vr.vecds[434].value;SELF.val435:=vr.vecds[435].value;SELF.val436:=vr.vecds[436].value;SELF.val437:=vr.vecds[437].value;SELF.val438:=vr.vecds[438].value;SELF.val439:=vr.vecds[439].value;SELF.val440:=vr.vecds[440].value;SELF.val441:=vr.vecds[441].value;SELF.val442:=vr.vecds[442].value;SELF.val443:=vr.vecds[443].value;SELF.val444:=vr.vecds[444].value;SELF.val445:=vr.vecds[445].value;SELF.val446:=vr.vecds[446].value;SELF.val447:=vr.vecds[447].value;SELF.val448:=vr.vecds[448].value;SELF.val449:=vr.vecds[449].value;SELF.val450:=vr.vecds[450].value;SELF.val451:=vr.vecds[451].value;SELF.val452:=vr.vecds[452].value;SELF.val453:=vr.vecds[453].value;SELF.val454:=vr.vecds[454].value;SELF.val455:=vr.vecds[455].value;SELF.val456:=vr.vecds[456].value;SELF.val457:=vr.vecds[457].value;SELF.val458:=vr.vecds[458].value;SELF.val459:=vr.vecds[459].value;SELF.val460:=vr.vecds[460].value;SELF.val461:=vr.vecds[461].value;SELF.val462:=vr.vecds[462].value;SELF.val463:=vr.vecds[463].value;SELF.val464:=vr.vecds[464].value;SELF.val465:=vr.vecds[465].value;SELF.val466:=vr.vecds[466].value;SELF.val467:=vr.vecds[467].value;SELF.val468:=vr.vecds[468].value;SELF.val469:=vr.vecds[469].value;SELF.val470:=vr.vecds[470].value;SELF.val471:=vr.vecds[471].value;SELF.val472:=vr.vecds[472].value;SELF.val473:=vr.vecds[473].value;SELF.val474:=vr.vecds[474].value;SELF.val475:=vr.vecds[475].value;SELF.val476:=vr.vecds[476].value;SELF.val477:=vr.vecds[477].value;SELF.val478:=vr.vecds[478].value;SELF.val479:=vr.vecds[479].value;SELF.val480:=vr.vecds[480].value;SELF.val481:=vr.vecds[481].value;SELF.val482:=vr.vecds[482].value;SELF.val483:=vr.vecds[483].value;SELF.val484:=vr.vecds[484].value;SELF.val485:=vr.vecds[485].value;SELF.val486:=vr.vecds[486].value;SELF.val487:=vr.vecds[487].value;SELF.val488:=vr.vecds[488].value;SELF.val489:=vr.vecds[489].value;SELF.val490:=vr.vecds[490].value;SELF.val491:=vr.vecds[491].value;SELF.val492:=vr.vecds[492].value;SELF.val493:=vr.vecds[493].value;SELF.val494:=vr.vecds[494].value;SELF.val495:=vr.vecds[495].value;SELF.val496:=vr.vecds[496].value;SELF.val497:=vr.vecds[497].value;SELF.val498:=vr.vecds[498].value;SELF.val499:=vr.vecds[499].value;SELF.val500:=vr.vecds[500].value;SELF.val501:=vr.vecds[501].value;SELF.val502:=vr.vecds[502].value;SELF.val503:=vr.vecds[503].value;SELF.val504:=vr.vecds[504].value;SELF.val505:=vr.vecds[505].value;SELF.val506:=vr.vecds[506].value;SELF.val507:=vr.vecds[507].value;SELF.val508:=vr.vecds[508].value;SELF.val509:=vr.vecds[509].value;SELF.val510:=vr.vecds[510].value;SELF.val511:=vr.vecds[511].value;SELF.val512:=vr.vecds[512].value;SELF.val513:=vr.vecds[513].value;SELF.val514:=vr.vecds[514].value;SELF.val515:=vr.vecds[515].value;SELF.val516:=vr.vecds[516].value;SELF.val517:=vr.vecds[517].value;SELF.val518:=vr.vecds[518].value;SELF.val519:=vr.vecds[519].value;SELF.val520:=vr.vecds[520].value;SELF.val521:=vr.vecds[521].value;SELF.val522:=vr.vecds[522].value;SELF.val523:=vr.vecds[523].value;SELF.val524:=vr.vecds[524].value;SELF.val525:=vr.vecds[525].value;SELF.val526:=vr.vecds[526].value;SELF.val527:=vr.vecds[527].value;SELF.val528:=vr.vecds[528].value;SELF.val529:=vr.vecds[529].value;SELF.val530:=vr.vecds[530].value;SELF.val531:=vr.vecds[531].value;SELF.val532:=vr.vecds[532].value;SELF.val533:=vr.vecds[533].value;SELF.val534:=vr.vecds[534].value;SELF.val535:=vr.vecds[535].value;SELF.val536:=vr.vecds[536].value;SELF.val537:=vr.vecds[537].value;SELF.val538:=vr.vecds[538].value;SELF.val539:=vr.vecds[539].value;SELF.val540:=vr.vecds[540].value;SELF.val541:=vr.vecds[541].value;SELF.val542:=vr.vecds[542].value;SELF.val543:=vr.vecds[543].value;SELF.val544:=vr.vecds[544].value;SELF.val545:=vr.vecds[545].value;SELF.val546:=vr.vecds[546].value;SELF.val547:=vr.vecds[547].value;SELF.val548:=vr.vecds[548].value;SELF.val549:=vr.vecds[549].value;SELF.val550:=vr.vecds[550].value;SELF.val551:=vr.vecds[551].value;SELF.val552:=vr.vecds[552].value;SELF.val553:=vr.vecds[553].value;SELF.val554:=vr.vecds[554].value;SELF.val555:=vr.vecds[555].value;SELF.val556:=vr.vecds[556].value;SELF.val557:=vr.vecds[557].value;SELF.val558:=vr.vecds[558].value;SELF.val559:=vr.vecds[559].value;SELF.val560:=vr.vecds[560].value;SELF.val561:=vr.vecds[561].value;SELF.val562:=vr.vecds[562].value;SELF.val563:=vr.vecds[563].value;SELF.val564:=vr.vecds[564].value;SELF.val565:=vr.vecds[565].value;SELF.val566:=vr.vecds[566].value;SELF.val567:=vr.vecds[567].value;SELF.val568:=vr.vecds[568].value;SELF.val569:=vr.vecds[569].value;SELF.val570:=vr.vecds[570].value;SELF.val571:=vr.vecds[571].value;SELF.val572:=vr.vecds[572].value;SELF.val573:=vr.vecds[573].value;SELF.val574:=vr.vecds[574].value;SELF.val575:=vr.vecds[575].value;SELF.val576:=vr.vecds[576].value;SELF.val577:=vr.vecds[577].value;SELF.val578:=vr.vecds[578].value;SELF.val579:=vr.vecds[579].value;SELF.val580:=vr.vecds[580].value;SELF.val581:=vr.vecds[581].value;SELF.val582:=vr.vecds[582].value;SELF.val583:=vr.vecds[583].value;SELF.val584:=vr.vecds[584].value;SELF.val585:=vr.vecds[585].value;SELF.val586:=vr.vecds[586].value;SELF.val587:=vr.vecds[587].value;SELF.val588:=vr.vecds[588].value;SELF.val589:=vr.vecds[589].value;SELF.val590:=vr.vecds[590].value;SELF.val591:=vr.vecds[591].value;SELF.val592:=vr.vecds[592].value;SELF.val593:=vr.vecds[593].value;SELF.val594:=vr.vecds[594].value;SELF.val595:=vr.vecds[595].value;SELF.val596:=vr.vecds[596].value;SELF.val597:=vr.vecds[597].value;SELF.val598:=vr.vecds[598].value;SELF.val599:=vr.vecds[599].value;SELF.val600:=vr.vecds[600].value;SELF.val601:=vr.vecds[601].value;SELF.val602:=vr.vecds[602].value;SELF.val603:=vr.vecds[603].value;SELF.val604:=vr.vecds[604].value;SELF.val605:=vr.vecds[605].value;SELF.val606:=vr.vecds[606].value;SELF.val607:=vr.vecds[607].value;SELF.val608:=vr.vecds[608].value;SELF.val609:=vr.vecds[609].value;SELF.val610:=vr.vecds[610].value;SELF.val611:=vr.vecds[611].value;SELF.val612:=vr.vecds[612].value;SELF.val613:=vr.vecds[613].value;SELF.val614:=vr.vecds[614].value;SELF.val615:=vr.vecds[615].value;SELF.val616:=vr.vecds[616].value;SELF.val617:=vr.vecds[617].value;SELF.val618:=vr.vecds[618].value;SELF.val619:=vr.vecds[619].value;SELF.val620:=vr.vecds[620].value;SELF.val621:=vr.vecds[621].value;SELF.val622:=vr.vecds[622].value;SELF.val623:=vr.vecds[623].value;SELF.val624:=vr.vecds[624].value;SELF.val625:=vr.vecds[625].value;SELF.val626:=vr.vecds[626].value;SELF.val627:=vr.vecds[627].value;SELF.val628:=vr.vecds[628].value;SELF.val629:=vr.vecds[629].value;SELF.val630:=vr.vecds[630].value;SELF.val631:=vr.vecds[631].value;SELF.val632:=vr.vecds[632].value;SELF.val633:=vr.vecds[633].value;SELF.val634:=vr.vecds[634].value;SELF.val635:=vr.vecds[635].value;SELF.val636:=vr.vecds[636].value;SELF.val637:=vr.vecds[637].value;SELF.val638:=vr.vecds[638].value;SELF.val639:=vr.vecds[639].value;SELF.val640:=vr.vecds[640].value;SELF.val641:=vr.vecds[641].value;SELF.val642:=vr.vecds[642].value;SELF.val643:=vr.vecds[643].value;SELF.val644:=vr.vecds[644].value;SELF.val645:=vr.vecds[645].value;SELF.val646:=vr.vecds[646].value;SELF.val647:=vr.vecds[647].value;SELF.val648:=vr.vecds[648].value;SELF.val649:=vr.vecds[649].value;SELF.val650:=vr.vecds[650].value;SELF.val651:=vr.vecds[651].value;SELF.val652:=vr.vecds[652].value;SELF.val653:=vr.vecds[653].value;SELF.val654:=vr.vecds[654].value;SELF.val655:=vr.vecds[655].value;SELF.val656:=vr.vecds[656].value;SELF.val657:=vr.vecds[657].value;SELF.val658:=vr.vecds[658].value;SELF.val659:=vr.vecds[659].value;SELF.val660:=vr.vecds[660].value;SELF.val661:=vr.vecds[661].value;SELF.val662:=vr.vecds[662].value;SELF.val663:=vr.vecds[663].value;SELF.val664:=vr.vecds[664].value;SELF.val665:=vr.vecds[665].value;SELF.val666:=vr.vecds[666].value;SELF.val667:=vr.vecds[667].value;SELF.val668:=vr.vecds[668].value;SELF.val669:=vr.vecds[669].value;SELF.val670:=vr.vecds[670].value;SELF.val671:=vr.vecds[671].value;SELF.val672:=vr.vecds[672].value;SELF.val673:=vr.vecds[673].value;SELF.val674:=vr.vecds[674].value;SELF.val675:=vr.vecds[675].value;SELF.val676:=vr.vecds[676].value;SELF.val677:=vr.vecds[677].value;SELF.val678:=vr.vecds[678].value;SELF.val679:=vr.vecds[679].value;SELF.val680:=vr.vecds[680].value;SELF.val681:=vr.vecds[681].value;SELF.val682:=vr.vecds[682].value;SELF.val683:=vr.vecds[683].value;SELF.val684:=vr.vecds[684].value;SELF.val685:=vr.vecds[685].value;SELF.val686:=vr.vecds[686].value;SELF.val687:=vr.vecds[687].value;SELF.val688:=vr.vecds[688].value;SELF.val689:=vr.vecds[689].value;SELF.val690:=vr.vecds[690].value;SELF.val691:=vr.vecds[691].value;SELF.val692:=vr.vecds[692].value;SELF.val693:=vr.vecds[693].value;SELF.val694:=vr.vecds[694].value;SELF.val695:=vr.vecds[695].value;SELF.val696:=vr.vecds[696].value;SELF.val697:=vr.vecds[697].value;SELF.val698:=vr.vecds[698].value;SELF.val699:=vr.vecds[699].value;SELF.val700:=vr.vecds[700].value;SELF.val701:=vr.vecds[701].value;SELF.val702:=vr.vecds[702].value;SELF.val703:=vr.vecds[703].value;SELF.val704:=vr.vecds[704].value;SELF.val705:=vr.vecds[705].value;SELF.val706:=vr.vecds[706].value;SELF.val707:=vr.vecds[707].value;SELF.val708:=vr.vecds[708].value;SELF.val709:=vr.vecds[709].value;SELF.val710:=vr.vecds[710].value;SELF.val711:=vr.vecds[711].value;SELF.val712:=vr.vecds[712].value;SELF.val713:=vr.vecds[713].value;SELF.val714:=vr.vecds[714].value;SELF.val715:=vr.vecds[715].value;SELF.val716:=vr.vecds[716].value;SELF.val717:=vr.vecds[717].value;SELF.val718:=vr.vecds[718].value;SELF.val719:=vr.vecds[719].value;SELF.val720:=vr.vecds[720].value;SELF.val721:=vr.vecds[721].value;SELF.val722:=vr.vecds[722].value;SELF.val723:=vr.vecds[723].value;SELF.val724:=vr.vecds[724].value;SELF.val725:=vr.vecds[725].value;SELF.val726:=vr.vecds[726].value;SELF.val727:=vr.vecds[727].value;SELF.val728:=vr.vecds[728].value;SELF.val729:=vr.vecds[729].value;SELF.val730:=vr.vecds[730].value;SELF.val731:=vr.vecds[731].value;SELF.val732:=vr.vecds[732].value;SELF.val733:=vr.vecds[733].value;SELF.val734:=vr.vecds[734].value;SELF.val735:=vr.vecds[735].value;SELF.val736:=vr.vecds[736].value;SELF.val737:=vr.vecds[737].value;SELF.val738:=vr.vecds[738].value;SELF.val739:=vr.vecds[739].value;SELF.val740:=vr.vecds[740].value;SELF.val741:=vr.vecds[741].value;SELF.val742:=vr.vecds[742].value;SELF.val743:=vr.vecds[743].value;SELF.val744:=vr.vecds[744].value;SELF.val745:=vr.vecds[745].value;SELF.val746:=vr.vecds[746].value;SELF.val747:=vr.vecds[747].value;SELF.val748:=vr.vecds[748].value;SELF.val749:=vr.vecds[749].value;SELF.val750:=vr.vecds[750].value;SELF.val751:=vr.vecds[751].value;SELF.val752:=vr.vecds[752].value;SELF.val753:=vr.vecds[753].value;SELF.val754:=vr.vecds[754].value;SELF.val755:=vr.vecds[755].value;SELF.val756:=vr.vecds[756].value;SELF.val757:=vr.vecds[757].value;SELF.val758:=vr.vecds[758].value;SELF.val759:=vr.vecds[759].value;SELF.val760:=vr.vecds[760].value;SELF.val761:=vr.vecds[761].value;SELF.val762:=vr.vecds[762].value;SELF.val763:=vr.vecds[763].value;SELF.val764:=vr.vecds[764].value;SELF.val765:=vr.vecds[765].value;SELF.val766:=vr.vecds[766].value;SELF.val767:=vr.vecds[767].value;SELF.val768:=vr.vecds[768].value;SELF.val769:=vr.vecds[769].value;SELF.val770:=vr.vecds[770].value;SELF.val771:=vr.vecds[771].value;SELF.val772:=vr.vecds[772].value;SELF.val773:=vr.vecds[773].value;SELF.val774:=vr.vecds[774].value;SELF.val775:=vr.vecds[775].value;SELF.val776:=vr.vecds[776].value;SELF.val777:=vr.vecds[777].value;SELF.val778:=vr.vecds[778].value;SELF.val779:=vr.vecds[779].value;SELF.val780:=vr.vecds[780].value;SELF.val781:=vr.vecds[781].value;SELF.val782:=vr.vecds[782].value;SELF.val783:=vr.vecds[783].value;SELF.val784:=vr.vecds[784].value;SELF.val785:=vr.vecds[785].value;SELF.val786:=vr.vecds[786].value;SELF.val787:=vr.vecds[787].value;SELF.val788:=vr.vecds[788].value;SELF.val789:=vr.vecds[789].value;SELF.val790:=vr.vecds[790].value;SELF.val791:=vr.vecds[791].value;SELF.val792:=vr.vecds[792].value;SELF.val793:=vr.vecds[793].value;SELF.val794:=vr.vecds[794].value;SELF.val795:=vr.vecds[795].value;SELF.val796:=vr.vecds[796].value;SELF.val797:=vr.vecds[797].value;SELF.val798:=vr.vecds[798].value;SELF.val799:=vr.vecds[799].value;SELF.val800:=vr.vecds[800].value;
        //END;

        input_tofield := PROJECT(vec_as_ds,nastyT(LEFT));

        numericrec := RECORD
            UNSIGNED id := input_tofield.id;
            REAL8 val1 := input_tofield.val1;
            REAL8 val2 := input_tofield.val2;
            REAL8 val3 := input_tofield.val3;
            REAL8 val4 := input_tofield.val4;
            REAL8 val5 := input_tofield.val5;
            REAL8 val6 := input_tofield.val6;
            REAL8 val7 := input_tofield.val7;
            REAL8 val8 := input_tofield.val8;
            REAL8 val9 := input_tofield.val9;
            REAL8 val10 := input_tofield.val10;
            REAL8 val11 := input_tofield.val11;
            REAL8 val12 := input_tofield.val12;
            REAL8 val13 := input_tofield.val13;
            REAL8 val14 := input_tofield.val14;
            REAL8 val15 := input_tofield.val15;
            REAL8 val16 := input_tofield.val16;
            REAL8 val17 := input_tofield.val17;
            REAL8 val18 := input_tofield.val18;
            REAL8 val19 := input_tofield.val19;
            REAL8 val20 := input_tofield.val20;
            REAL8 val21 := input_tofield.val21;
            REAL8 val22 := input_tofield.val22;
            REAL8 val23 := input_tofield.val23;
            REAL8 val24 := input_tofield.val24;
            REAL8 val25 := input_tofield.val25;
            REAL8 val26 := input_tofield.val26;
            REAL8 val27 := input_tofield.val27;
            REAL8 val28 := input_tofield.val28;
            REAL8 val29 := input_tofield.val29;
            REAL8 val30 := input_tofield.val30;
            REAL8 val31 := input_tofield.val31;
            REAL8 val32 := input_tofield.val32;
            REAL8 val33 := input_tofield.val33;
            REAL8 val34 := input_tofield.val34;
            REAL8 val35 := input_tofield.val35;
            REAL8 val36 := input_tofield.val36;
            REAL8 val37 := input_tofield.val37;
            REAL8 val38 := input_tofield.val38;
            REAL8 val39 := input_tofield.val39;
            REAL8 val40 := input_tofield.val40;
            REAL8 val41 := input_tofield.val41;
            REAL8 val42 := input_tofield.val42;
            REAL8 val43 := input_tofield.val43;
            REAL8 val44 := input_tofield.val44;
            REAL8 val45 := input_tofield.val45;
            REAL8 val46 := input_tofield.val46;
            REAL8 val47 := input_tofield.val47;
            REAL8 val48 := input_tofield.val48;
            REAL8 val49 := input_tofield.val49;
            REAL8 val50 := input_tofield.val50;
            REAL8 val51 := input_tofield.val51;
            REAL8 val52 := input_tofield.val52;
            REAL8 val53 := input_tofield.val53;
            REAL8 val54 := input_tofield.val54;
            REAL8 val55 := input_tofield.val55;
            REAL8 val56 := input_tofield.val56;
            REAL8 val57 := input_tofield.val57;
            REAL8 val58 := input_tofield.val58;
            REAL8 val59 := input_tofield.val59;
            REAL8 val60 := input_tofield.val60;
            REAL8 val61 := input_tofield.val61;
            REAL8 val62 := input_tofield.val62;
            REAL8 val63 := input_tofield.val63;
            REAL8 val64 := input_tofield.val64;
            REAL8 val65 := input_tofield.val65;
            REAL8 val66 := input_tofield.val66;
            REAL8 val67 := input_tofield.val67;
            REAL8 val68 := input_tofield.val68;
            REAL8 val69 := input_tofield.val69;
            REAL8 val70 := input_tofield.val70;
            REAL8 val71 := input_tofield.val71;
            REAL8 val72 := input_tofield.val72;
            REAL8 val73 := input_tofield.val73;
            REAL8 val74 := input_tofield.val74;
            REAL8 val75 := input_tofield.val75;
            REAL8 val76 := input_tofield.val76;
            REAL8 val77 := input_tofield.val77;
            REAL8 val78 := input_tofield.val78;
            REAL8 val79 := input_tofield.val79;
            REAL8 val80 := input_tofield.val80;
            REAL8 val81 := input_tofield.val81;
            REAL8 val82 := input_tofield.val82;
            REAL8 val83 := input_tofield.val83;
            REAL8 val84 := input_tofield.val84;
            REAL8 val85 := input_tofield.val85;
            REAL8 val86 := input_tofield.val86;
            REAL8 val87 := input_tofield.val87;
            REAL8 val88 := input_tofield.val88;
            REAL8 val89 := input_tofield.val89;
            REAL8 val90 := input_tofield.val90;
            REAL8 val91 := input_tofield.val91;
            REAL8 val92 := input_tofield.val92;
            REAL8 val93 := input_tofield.val93;
            REAL8 val94 := input_tofield.val94;
            REAL8 val95 := input_tofield.val95;
            REAL8 val96 := input_tofield.val96;
            REAL8 val97 := input_tofield.val97;
            REAL8 val98 := input_tofield.val98;
            REAL8 val99 := input_tofield.val99;
            REAL8 val100 := input_tofield.val100;
        END;

        input_tonumfield := TABLE(input_tofield,numericrec);

        //ML_Core.ToField(input_tofield,X);
        ML_Core.ToField(input_tonumfield,X);

        Y := PROJECT(input_tofield,TRANSFORM(ML_Core.Types.DiscreteField,SELF.wi := 1,SELF.value := LEFT.label,SELF.id := LEFT.id,SELF.number := 1));
        
        result := MODULE
            EXPORT NUMF := X;
            EXPORT DSCF := Y;
        END;
        RETURN result;
    END;
    
    EXPORT getDiscreteField(DATASET(trainrec) tr) := FUNCTION
        lblintrec := RECORD
            UNSIGNED rowid;
            INTEGER4 label;
        END;

        lblintrec lblintT(trainrec t,INTEGER C) := TRANSFORM
            SELF.rowid := C;
            SELF.label := (INTEGER4)t.label;
        END;

        output_tofield := PROJECT(tr,lblintT(LEFT,COUNTER));

        Y := PROJECT(output_tofield,TRANSFORM(ML_Core.Types.DiscreteField,SELF.wi := 1,SELF.value := LEFT.label,SELF.id := LEFT.rowid,SELF.number := 1));

        RETURN Y;
    END;


    //FIXME: Add BLR parameters as arguments
    EXPORT train_binlogreg(DATASET(trainrec) tr,INTEGER iters = 100) := FUNCTION

        //train_feats := getNumericField(tr);
        //train_label := getDiscreteField(tr);
        fieldform := getFields(tr);
        train_feats := fieldform.NUMF;
        train_label := fieldform.DSCF;

        blr := BinomialLogisticRegression(iters,.000000000001,LogisticRegression.Constants.default_ridge);
        mod := blr.getModel(train_feats,train_label);
        RETURN mod;
    END;
END;