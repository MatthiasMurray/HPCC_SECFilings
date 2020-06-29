IMPORT ML_Core;
IMPORT ML_Core.Types as CTypes;

twi := CTypes.t_Work_item;

OUTPUT('this was a test');
OUTPUT(DATASET([{1},{2}],{twi val}));