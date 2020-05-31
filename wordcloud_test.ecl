IMPORT * FROM SEC_Viz;
IMPORT Visualizer FROM Visualizer AS Visualizer;

path := '~ncf::edgarfilings::raw::tech10qs_group';

OUTPUT(sec_wordcloud.word_freqs(path,'SEC'));
wcloud := Visualizer.TwoD.WordCloud('WordCloud',, 'Chart2D__test');
wcloud;