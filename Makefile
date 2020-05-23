

ISO639_DOWNLOADS = https://iso639-3.sil.org/sites/iso639-3/files/downloads

ISO639_TABLES = iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab \
		iso-639-3_Code_Tables_20200130/iso-639-3-macrolanguages_20200130.tab \
		non-standard.tab \
		iso-639-3_Code_Tables_20200130/iso-639-3_Retirements_20200130.tab


all: ISO-639_3/lib/ISO/639_3.pm

ISO-639_3:
	module-starter --module=ISO::639_3 \
		--author="Joerg Tiedemann" \
		--email=tiedemann@cpan.org

ISO-639_3/lib/ISO/639_3.pm: iso639
	cp $< $@

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
	chmod +x $@

iso-639-3_Code_Tables_20200130:
	wget ${ISO639_DOWNLOADS}/$@.zip
	unzip $@.zip
	rm -f $@.zip

iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab:
	${MAKE} iso-639-3_Code_Tables_20200130

iso-639-3_Code_Tables_20200130/iso-639-3-macrolanguages_20200130.tab iso-639-3_Code_Tables_20200130/iso-639-3_Retirements_20200130.tab: iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab
	@echo ""
