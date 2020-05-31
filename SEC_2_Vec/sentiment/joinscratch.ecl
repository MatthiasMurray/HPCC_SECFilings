IMPORT TextVectors as tv;
IMPORT * FROM SEC_2_Vec.sentiment;
TextMod := tv.Types.TextMod;
t_Vector:= tv.Types.t_Vector;
path := '~ncf::edgarfilings::raw::tech10qs_group';
ss := sent_setup(path);
TfIdfRec:= ss.tfidfrec;

word2vecs := DATASET(WORKUNIT('W20200527-023139','Result 1'),TextMod);

tfidfvals := DATASET(WORKUNIT('W20200531-033102','Tech_TFIDF'),TfIdfRec);

w2v := RECORD
    STRING text := word2vecs.text;
    t_Vector vec:= word2vecs.vec;
END;

wordvec_simp := TABLE(word2vecs,w2v);

tf_withvecs := JOIN(wordvec_simp,tfidfvals,LEFT.text=RIGHT.word);

OUTPUT('placeholder');