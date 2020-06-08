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

    EXPORT trndata_wlbl (STRING path,BOOLEAN labelnames=TRUE) := FUNCTION
        rawsents := secvec_input_lbl(path,labelnames);
        rawrec := RECORD
            UNSIGNED8 sentId := rawsents.sentId;
            STRING text := rawsents.text;
        END;
        outlblrec := RECORD
            UNSIGNED8 sentId := rawsents.sentId;
            STRING label := rawsents.label;
        END;
        jrec := RECORD(TextMod)
            STRING label;
        END;

        trainSentences := TABLE(rawsents,rawrec);
        labelSentences := TABLE(rawsents,outlblrec);

        sv := tv.SentenceVectors();
        model := sv.GetModel(trainSentences);
        sentmod := model(typ=2);

        trainrec lrT(TextMod s,DATASET(outlblrec) r) := TRANSFORM
            SELF.id := s.id;
            SELF.text := s.text;
            SELF.vec := s.vec;
            SELF.label := r(sentId = s.id)[1].label;
        END;

        out := PROJECT(sentmod,lrT(LEFT,labelSentences));

        RETURN out;
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

    EXPORT getNumericField(trainrec tr) := FUNCTION
        

        
        nf_firstrec firstT(trainrec tr_Row) := TRANSFORM
        //mlTypes.NumericField firstT(trainrec t) := TRANSFORM
            SELF.wi := 1;
            SELF.id := 0;
            SELF.numvals := tvec_to_numval(tr_Row.vec);
        END;

        step1 := PROJECT(tr,firstT(LEFT));
        RETURN step1;
    END;
    //     mlTypes.NumericField finalT(mlTypes.NumericField s1,mlTypes.NumericField s2) := TRANSFORM
    //         SELF.id := s1.id + s2.wi;
    //         SELF := s2;
    //     END;

    //     out := ITERATE(step1,finalT(LEFT,RIGHT));

    //     RETURN out;
    // END;

    EXPORT train_binlogreg(trainrec tr) := FUNCTION

        trainDatrec := RECORD
            tv.Types.t_Vector vec;
            INTEGER label;
        END;

        trainDatrec makeTrain(trainrec t) := TRANSFORM
            SELF.vec := t.vec;
            SELF.label := (INTEGER) t.label;
        END;
        
        trainDat := PROJECT(tr,makeTrain(LEFT));

        blm := BinomialLogisticRegression;//.GetModel(trainDat);
        //mod := blm.GetModel()
        RETURN '';
    END;
END;