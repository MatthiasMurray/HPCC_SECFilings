IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression as LR;

#OPTION('outputLimit',1750);

trainrec := sent_model.trainrec;
sveclrec := sent_model.sveclblrec;

path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

rsentsk := secvec_input_lbl(path10k,TRUE,'plain');
rsentsq := secvec_input_lbl(path10q,TRUE,'plain');

tick10k := '~ncf::edgarfilings::supp::ticks_10k';

csvrec := RECORD
    STRING ticker;
END;

tickraw := DATASET(tick10k,csvrec,CSV(HEADING(1)));
ticks := SET(tickraw,tickraw.ticker);

get_tick(STRING f) := FUNCTION
    parts := STD.Str.SplitWords(f,'_',FALSE);
    RETURN parts[1];
END;

q_in10k := rsentsq(get_tick(TRIM(fname,ALL)) IN ticks);

tick_in10qk := DEDUP(PROJECT(q_in10k,TRANSFORM(csvrec,SELF.ticker:=get_tick(TRIM(LEFT.fname)))),ticker);
ticksqk := SET(tick_in10qk,tick_in10qk.ticker);

k_in10qk := rsentsk(get_tick(TRIM(fname,ALL)) IN ticksqk);

//rsents := rsentsk + q_in10k;
rsents := k_in10qk + q_in10k;

trainsentrec := RECORD
    UNSIGNED8 sentId := rsents.sentId;
    STRING text := rsents.text;
END;

trainsents := TABLE(rsents,trainsentrec);

sv := tv.SentenceVectors();
mod := sv.GetModel(trainsents);

OUTPUT(rsents,ALL);
OUTPUT(mod,ALL);

//dat := sent_model.trndata_wlbl(rsents);

//dat_vn_all := dat[1];
//dat_tf_all := dat[2];

//OUTPUT(rsents,ALL,NAMED('sents_qk'));
//OUTPUT(dat_vn_all,ALL,NAMED('vanilla_all'));
//OUTPUT(dat_tf_all,ALL,NAMED('tfidf_all'));