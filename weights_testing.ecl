IMPORT * FROM TextVectors.Types;

oldweights := DATASET(WORKUNIT('W20200528-021727','Result 1'),Types.SliceExt);
OUTPUT(oldweights);