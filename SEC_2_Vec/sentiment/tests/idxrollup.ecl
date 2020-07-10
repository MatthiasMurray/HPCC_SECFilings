inds := DATASET([{'a'},{'b'},{'c'}],{STRING letter});

idxrec := RECORD
    UNSIGNED8 id;
    STRING letter;
END;

idxhelprec := RECORD
    UNSIGNED8 id := 0;
    STRING letter := inds.letter;
END;

midds := TABLE(inds,idxhelprec);

idxrec idx_T(idxrec dl,idxrec dr) := TRANSFORM
    SELF.id := dl.id + 1;
    SELF.letter := dr.letter;
END;

out := ITERATE(midds,idx_T(LEFT,RIGHT));

OUTPUT(out);