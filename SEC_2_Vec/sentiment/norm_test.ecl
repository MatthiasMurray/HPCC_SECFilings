lsetrec := RECORD
    INTEGER setId;
    STRING setlet;
END;
lset := DATASET([{1,'a'},{2,'b'},{3,'c'}],lsetrec);
rsetrec := RECORD
    STRING sentence;
END;
sent := DATASET([{'the quick brown fox'},{'jumped over the lazy dog'}],rsetrec);

outrec := RECORD
    INTEGER setId;
    STRING setlet;
    STRING sentence;
END;

OUTPUT(NORMALIZE(lset,COUNT(sent),TRANSFORM(outrec,
                            SELF.setId := LEFT.setId,
                            SELF.setlet := LEFT.setlet,
                            SELF.sentence := sent[COUNTER].sentence)));