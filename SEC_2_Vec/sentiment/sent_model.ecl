IMPORT * FROM SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment as s;
IMPORT * FROM s;
IMPORT TextVectors as tv;
IMPORT tv.Types AS Types;
IMPORT * FROM Types;
IMPORT * FROM ML_Core;
IMPORT ML_Core.Types as mlTypes;
IMPORT ML_Core.Interfaces;

Sentence := tv.Types.Sentence;
TextMod := tv.Types.TextMod;

EXPORT sent_model := MODULE
    EXPORT trndata_wlbl (STRING path,labelnames=TRUE) := FUNCTION
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

        finalrec := RECORD
            tv.Types.t_TextId id;
            tv.Types.t_Sentence text;
            tv.Types.t_Vector vec;
            STRING label;
        END;

        finalrec lrT(TextMod s,DATASET(outlblrec) r) := TRANSFORM
            SELF.id := s.id;
            SELF.text := s.text;
            SELF.vec := s.vec;
            SELF.label := r(sentId = s.id)[1].label;
        END;

        out := PROJECT(sentmod,lrT(LEFT,labelSentences));

        RETURN out;
    END;
END;