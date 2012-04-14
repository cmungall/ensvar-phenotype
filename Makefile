AONTS = DO HP MP omim snomed_disorder
AFILES = $(patsubst %, align-%.txt, $(AONTS))

align-%.txt: ensvar-phenotype.obo
	blip-findall -consult nlp_filter.pro -u metadata_nlp -u metadata_nlp_disorder_hook -goal index_entity_pair_label_match -i $< -r $* "entity_pair_label_reciprocal_best_intermatch(A,B,S)" -use_tabs -label -no_pred > $@.tmp && grep -v UMLS: $@.tmp |  sort -u > $@
.PRECIOUS: align-%.txt

all_align.txt: $(AFILES)
	cat $(AFILES) | grep ^ENS | cut -f1-4 | sort -u > $@

summary.txt: ensvar-phenotype.obo all_align.txt
	blip-findall -i all_align.txt -i $< "class(X,XN),findall(Y,all_align(X,_,Y,_),Ys),findall(Y,all_align(X,_,_,Y),Zs)" -select "x(X,XN,Ys,Zs)"  -no_pred > $@

%.owlpl: %.owl
	thea --format rdf_direct $< --to owlpl > $@

align-xp.txt:
	blip-findall -r uberonp -r human_phenotype_xp -r HP -i snomed-disorder.obo -i snomed-morph.obo -i snomed-anat.obo -r pato -r FMA -i snomed-disorder-hack.owlpl -consult compare.pro -goal xload,ix x/8 -label > $@.tmp && sort -u $@.tmp > $@
