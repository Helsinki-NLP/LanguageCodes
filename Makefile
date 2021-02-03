

ISO639_DOWNLOADS = https://iso639-3.sil.org/sites/iso639-3/files/downloads

ISO639_TABLES = data/iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab \
		data/iso-639-3_Code_Tables_20200130/iso-639-3-macrolanguages_20200130.tab \
		data/non-standard.tab \
		data/iso-639-3_Code_Tables_20200130/iso-639-3_Retirements_20200130.tab \
		data/collective-language-codes.tab \
		data/iso639-5.tsv


all: ISO-639-3/lib/ISO/639/3.pm ISO-639-5/lib/ISO/639/5.pm ISO-15924/lib/ISO/15924.pm

ISO-639-3:
	module-starter --module=ISO::639::3 \
		--author="Joerg Tiedemann" \
		--email=tiedemann@cpan.org

ISO-639-5:
	module-starter --module=ISO::639::5 \
		--author="Joerg Tiedemann" \
		--email=tiedemann@cpan.org

ISO-15924:
	module-starter --module=ISO::15924 \
		--author="Joerg Tiedemann" \
		--email=tiedemann@cpan.org


## Alt 1:
## with plain data read on-the-fly
ISO-639-3/lib/ISO/639/3.pm: iso639
	mkdir -p ${dir $@}
	cp $< $@

## Alt 2:
## with variables generated from plain data tables
##
# ISO-639-3/lib/ISO/639/3.pm: iso639-3.head iso639-3.data iso639-3.tail
#	mkdir -p ${dir $@}
#	cat $^ > $@

ISO3_DATA_FILES = data/iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab \
    data/iso-639-3_Code_Tables_20200130/iso-639-3-macrolanguages_20200130.tab \
    data/non-standard.tab \
    data/iso-639-3_Code_Tables_20200130/iso-639-3_Retirements_20200130.tab \
    data/collective-language-codes.tab \
    data/iso639-5.tsv

iso639-3.data: scripts/make-iso639-3.pl ${ISO3_DATA_FILES}
	perl $< > $@


ISO-639-5/lib/ISO/639/5.pm: iso639-5.head iso639-5.data iso639-5.tail
	mkdir -p ${dir $@}
	cat $^ > $@

ISO5_DATA_FILES = data/cldr/common/supplemental/languageGroup.xml \
		data/iso639-5-hierarchy.tsv \
		data/iso639-5-languages.tsv

iso639-5.data: scripts/make-iso639-5.pl ${ISO5_DATA_FILES}
	perl $< > $@


ISO-15924/lib/ISO/15924.pm: iso15924.head iso15924.data iso15924.tail
	mkdir -p ${dir $@}
	cat $^ > $@

iso15924.data: scripts/make-script-table.pl
	perl $< > $@


## NOTE: tables ond with newline! need to add them one-by-one
iso639: iso639.in ${ISO639_TABLES}
	cat $<    > $@
	@tr -d "\r" < $(word 2,$^) >> $@
	@echo "" >> $@
	@echo "" >> $@
	@tr -d "\r" < $(word 3,$^) >> $@
	@echo "" >> $@
	@echo "" >> $@
	@tr -d "\r" < $(word 4,$^) >> $@
	@echo "" >> $@
	@echo "" >> $@
	@tr -d "\r" < $(word 5,$^) >> $@
	@echo "" >> $@
	@echo "" >> $@
	@tr -d "\r" < $(word 6,$^) >> $@
	@echo "" >> $@
	@echo "" >> $@
	@tr -d "\r" < $(word 7,$^) >> $@
	chmod +x $@

data/iso-639-3_Code_Tables_20200130:
	wget ${ISO639_DOWNLOADS}/$@.zip
	unzip $@.zip
	rm -f $@.zip

data/iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab:
	${MAKE} iso-639-3_Code_Tables_20200130

data/iso-639-3_Code_Tables_20200130/iso-639-3-macrolanguages_20200130.tab data/iso-639-3_Code_Tables_20200130/iso-639-3_Retirements_20200130.tab: data/iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab
	@echo ""

## see http://id.loc.gov/vocabulary/iso639-5.html
data/iso639-5.tsv:
	wget -O $@ http://id.loc.gov/vocabulary/iso639-5.tsv

iso15924.txt.zip:
	wget https://www.unicode.org/iso15924/iso15924.txt.zip


OPUSLANGS = fi sv fr es de ar he cmn cn yue zhs zht zh ze_zh zh_cn zh_CN zh_HK zh_tw zh_TW zh_yue pt pt_br pt_BR pt_PT aa ab ace ach acm acu ada ady aeb aed ae afb afh af agr aha aii ain ajg aka ake akl ak aln alt alz amh ami amu am ang an aoc aoz apc ara arc arh arn arq ary arz ase asf ast as ati atj avk av awa aym ay azb az az_IR bal bam ban bar bas ba bbc bbj bci bcl bem ber be be_tarask bfi bg bho bhw bh bin bi bjn bm bn bnt bo bpy brx br bsn bs btg bts btx bua bug bum bvl bvy bxr byn byv bzj bzs cab cac cak cat cay ca cbk cbk_zam cce cdo ceb ce chf chj chk cho chq chr chw chy ch cjk cjp cjy ckb ckt cku cmo cnh cni cop co crh crh_latn crp crs cr csb cse csf csg csl csn csr cs cto ctu cuk cu cv cycl cyo cy daf da dga dhv dik din diq dje djk dng dop dsb dtp dty dua dv dws dyu dz ecs ee efi egl el eml enm eo esn  et eu ewo ext fan fat fa fcs ff fil fj fkv fon foo fo frm frp frr fse fsl fuc ful fur fuv fy gaa gag gan ga gbi gbm gcf gcr gd gil glk gl gn gom gor gos got grc gr gsg gsm gss gsw guc gug gum gur guw gu gv gxx gym hai hak hau haw ha haz hb hch hds hif hi hil him hmn hne hnj hoc ho hrx hr hsb hsh hsn ht hup hus hu hyw hy hz ia iba ibg ibo id ie ig ike ik ilo inh inl ins io iro ise ish iso is it iu izh jak jam jap ja jbo jdt jiv jmx jp jsl jv kaa kab kac kam kar kau ka kbd kbh kbp kea kek kg kha kik kin ki kjh kj kk kl kmb kmr km kn koi kok kon koo ko kpv kqn krc kri krl kr ksh kss ksw ks kum ku kvk kv kwn kwy kw kxi ky kzj lad lam la lbe lb ldn lez lfn lg lij lin liv li lkt lld lmo ln lou lo loz lrc lsp ltg lt lua lue lun luo lus luy lu lv lzh lzz mad mai mam map_bms mau max maz mco mcp mdf men me mfe mfs mgm mgr mg mhr mh mic min miq mi mk mlg ml mnc mni mnw mn moh mos mo mrj mrq mr ms ms_MY mt mus mvv mwl mww mxv myv my mzn mzy nah nan nap na nba nb nn no nb_NO nn_NO no_nb nog nch nci ncj ncs ncx ndc nds nds_nl nd new ne ngl ngt ngu ng nhg nhk nhn nia nij niu nlv nl nnh non nov npi nqo nrm nr nso nst nv nya nyk nyn nyu ny nzi oar oc ojb oj oke olo om orm orv or osx os ota ote otk pag pam pan pap pau pa pbb pcd pck pcm pdc pdt pes pfl pid pih pis pi plt pl pms pmy pnb pnt pon pot po ppk ppl prg prl prs pso psp psr ps pys quc que qug qus quw quy qu quz qvi qvz qya rap rar rcf rif rmn rms rmy rm rnd rn rom ro rsl rue run rup ru rw ry sah sat sa sbs scn sco sc sd seh se sfs sfw sgn sgs sg shi shn shs shy sh sid simple si sjn sk sl sma sml sm sna sn som son sop sot so sqk sq sr srp sr_ME srm srn ssp ss stq st sux su svk swa swc swg swh sw sxn syr szl ta ta_LK tcf tcy tc tdt tdx tet te tg tg_TJ thv th tig tir tiv ti tkl tk tlh tll tl tl_PH tly tmh tmp tmw tn tob tog toh toi toj toki top to tpi tpw trv tr tsc tss ts tsz ttj tt tum tvl tw tyv ty tzh tzl tzo udm ug uk umb urh ur ur_PK usp uz vec vep ve vi vi_VN vls vmw vo vro vsl wae wal war wa wba wes wls wlv wol wo wuu xal xho xh xmf xpe yao yap yaq ybb yi yor yo yua zab zai zam za zdj zea zib zlm zne zpa zpg zsl zsm zul zu zza

test: iso639
	@echo '${OPUSLANGS}' | tr ' ' "\n"  | grep . > tt1
	@./iso639 ${OPUSLANGS} | tr ' ' "\n"  > tt2
	@paste tt1 tt2

test-2: iso639
	@echo '${OPUSLANGS}' | tr ' ' "\n"  | grep . > tt1
	@./iso639 -2 -k ${OPUSLANGS} | tr ' ' "\n"  > tt2
	@paste tt1 tt2

test-3: iso639
	@echo '${OPUSLANGS}' | tr ' ' "\n"  | grep . > tt1
	@./iso639 -3 -k ${OPUSLANGS} | tr ' ' "\n"  > tt2
	@paste tt1 tt2

test-m: iso639
	@echo '${OPUSLANGS}' | tr ' ' "\n"  | grep . > tt1
	@./iso639 -m -k ${OPUSLANGS} | tr ' ' "\n"  > tt2
	@paste tt1 tt2

