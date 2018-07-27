require 'traject'

settings do
  provide 'solr.url', ENV['SOLR_URL']
  provide 'solr.version', ENV['SOLR_VERSION']
  provide 'processing_thread_pool', ENV['NUM_THREADS']
end

to_field 'id', extract_marc('001') do |_record, accumulator|
  accumulator.map! do |v|
    v.sub(/^a/, '')
  end
end

to_field 'marcxml', serialized_marc(
  format: 'xml',
  binary_escape: false,
  allow_oversized: true
)

# to_field 'marcbib_xml' #TODO

#all_search = custom, getAllFields
# vern_all_search = custom, getAllLinkedSearchableFields
# 
# # Title Search Fields
to_field 'title_245a_search', extract_marc('245a')
to_field 'vern_title_245a_search', extract_marc('245a', alternate_script: :only)
to_field 'title_245_search', extract_marc('245abfgknps')
to_field 'vern_title_245_search', extract_marc('245abfgknps', alternate_script: :only)
to_field 'title_uniform_search', extract_marc('130adfgklmnoprst:240adfgklmnoprs', first: true)
# vern_title_uniform_search = custom, getVernacular(130adfgklmnoprst:240adfgklmnoprs, first)
# title_variant_search = 210ab:222ab:242abnp:243adfgklmnoprs:246abfgnp:247abfgnp
# vern_title_variant_search = custom, getLinkedField(210ab:222ab:242abnp:243adfgklmnoprs:246abfgnp:247abfgnp)
# title_related_search = 505t:700fgklmnoprst:710dfgklmnoprst:711fgklnpst:730adfgklmnoprst:740anp:760st:762st:765st:767st:770st:772st:773st:774st:775st:776st:777st:780st:785st:786st:787st:796fgklmnoprst:797dfgklmnoprst:798fgklnpst:799adfgklmnoprst
# vern_title_related_search = custom, getLinkedField(505t:700fgklmnoprst:710dfgklmnoprst:711fgklnpst:730adfgklmnoprst:740anp:760st:762st:765st:767st:770st:772st:773st:774st:775st:776st:777st:780st:785st:786st:787st:796fgklmnoprst:797dfgklmnoprst:798fgklnpst:799adfgklmnoprst)
# # Title Display Fields
# title_245a_display = custom, removeTrailingPunct(245a, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
# vern_title_245a_display = custom, vernRemoveTrailingPunc(245a, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
# title_245c_display = custom, removeTrailingPunct(245c, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
# vern_title_245c_display = custom, vernRemoveTrailingPunc(245c, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
# # no sub c in title_display
# title_display = custom, removeTrailingPunct(245abdefghijklmnopqrstuvwxyz, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
# vern_title_display = custom, vernRemoveTrailingPunc(245abdefghijklmnopqrstuvwxyz, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
# title_full_display = custom, getAllAlphaSubfields(245)
# vern_title_full_display = custom, getLinkedField(245[a-z])
# # ? no longer will use title_uniform_display due to author-title searching needs ? 2010-11
# title_uniform_display = custom, getAllAlphaSubfields(130:240, first)
# vern_title_uniform_display = custom, getVernacular(130abcdefghijklmnopqrstuvwxyz:240abcdefghijklmnopqrstuvwxyz, first)
# # Title Sort Field
# title_sort = custom, getSortTitle
# 
# # Series Search Fields
# series_search = 440anpv:490av:800[a-x]:810[a-x]:811[a-x]:830[a-x]
# vern_series_search = custom, getLinkedField(440anpv:490av:800[a-x]:810[a-x]:811[a-x]:830[a-x])
# series_exact_search = 830a
# 
# # Author Title Search Fields
# author_title_search = custom, getAuthorTitleSearch
# 
# # Author Search Fields
# # IFF relevancy of author search needs improvement, unstemmed flavors for author search
# #   (keep using stemmed version for everything search to match stemmed query)
# author_1xx_search = 100abcdgjqu:110abcdgnu:111acdegjnqu
# vern_author_1xx_search = custom, getLinkedField(100abcdgjqu:110abcdgnu:111acdegjnqu)
# author_7xx_search = 700abcdgjqu:720ae:796abcdgjqu:710abcdgnu:797abcdgnu:711acdejngqu:798acdegjnqu
# vern_author_7xx_search = custom, getLinkedField(700abcdgjqu:720ae:796abcdgjqu:710abcdgnu:797abcdgnu:711acdegjnqu:798acdegjnqu)
# author_8xx_search = 800abcdegjqu:810abcdegnu:811acdegjnqu
# vern_author_8xx_search = custom, getLinkedField(800abcdegjqu:810abcdegnu:811acdegjnqu)
# # Author Facet Fields
# author_person_facet = custom, removeTrailingPunct(100abcdq:700abcdq, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,) )
# author_other_facet = custom, removeTrailingPunct(110abcdn:111acdn:710abcdn:711acdn, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,) )
# # Author Display Fields
# author_person_display = custom, removeTrailingPunct(100abcdq, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,) )
# vern_author_person_display = custom, vernRemoveTrailingPunc(100abcdq, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
# author_person_full_display = custom, getAllAlphaSubfields(100)
# vern_author_person_full_display = custom, getLinkedField(100[a-z])
# author_corp_display = custom, getAllAlphaSubfields(110)
# vern_author_corp_display = custom, getLinkedField(110[a-z])
# author_meeting_display = custom, getAllAlphaSubfields(111)
# vern_author_meeting_display = custom, getLinkedField(111[a-z])
# # Author Sort Field
# author_sort = custom, getSortableAuthor
# 
# # Subject Search Fields
# #  should these be split into more separate fields?  Could change relevancy if match is in field with fewer terms
# topic_search = custom, getTopicAllAlphaExcept(650vxyz:653vxyz:654vxyz:690vxyz)
# vern_topic_search = custom, getVernAllAlphaExcept(650vxyz:653vxyz:654vxyz:690vxyz)
# topic_subx_search = 600x:610x:611x:630x:650x:651x:655x:656x:657x:690x:691x:696x:697x:698x:699x
# vern_topic_subx_search = custom, getLinkedField(600x:610x:611x:630x:650x:651x:655x:656x:657x:690x:691x:696x:697x:698x:699x)
# geographic_search = custom, getAllAlphaExcept(651vxyz:691vxyz)
# vern_geographic_search = custom, getVernAllAlphaExcept(651vxyz:691vxyz)
# geographic_subz_search = 600z:610z:630z:650z:651z:654z:655z:656z:657z:690z:691z:696z:697z:698z:699z
# vern_geographic_subz_search = custom, getLinkedField(600z:610z:630z:650z:651z:654z:655z:656z:657z:690z:691z:696z:697z:698z:699z)
# subject_other_search = custom, getTopicAllAlphaExcept(600vxyz:610vxyz:611vxyz:630vxyz:655vxyz:656vxyz:657vxyz:658vxyz:696vxyz:697vxyz:698vxyz:699vxyz)
# vern_subject_other_search = custom, getVernAllAlphaExcept(600vxyz:610vxyz:611vxyz:630vxyz:655vxyz:656vxyz:657vxyz:658vxyz:696vxyz:697vxyz:698vxyz:699vxyz)
# subject_other_subvy_search = 600vy:610vy:611vy:630vy:650vy:651vy:654vy:655vy:656vy:657vy:690vy:691vy:696vy:697vy:698vy:699vy
# vern_subject_other_subvy_search = custom, getLinkedField(600vy:610vy:611vy:630vy:650vy:651vy:654vy:655vy:656vy:657vy:690vy:691vy:696vy:697vy:698vy:699vy)
# subject_all_search = custom, getAllAlphaSubfields(600:610:611:630:648:650:651:652:653:654:655:656:657:658:662:690:691:696:697:698:699)
# vern_subject_all_search = custom, getLinkedField(600[a-z]:610[a-z]:611[a-z]:630[a-z]:648[a-z]:650[a-z]:651[a-z]:652[a-z]:653[a-z]:654[a-z]:655[a-z]:656[a-z]:657[a-z]:658[a-z]:662[a-z]:690[a-z]:691[a-z]:696[a-z]:697[a-z]:698[a-z]:699[a-z])
# # Subject Facet Fields
# topic_facet = custom, getTopicWithoutTrailingPunct(600abcdq:600t:610ab:610t:630a:630t:650a, [\\\\,;:], ([\\p{L}\\p{N}]{4}|[A-Za-z]{3}|[\\)]) )
# geographic_facet = custom, getGeographicFacet([\\\\,;], ([A-Za-z0-9]{2}|\\)) )
# era_facet = custom, removeTrailingPunct(650y:651y, [\\\\,;], ([A-Za-z0-9]{2}) )
# 
# # Publication Fields
# pub_search = custom, getPublication
# vern_pub_search = custom, getLinkedField(260ab:264ab)
# pub_country = 008[15-17]:008[15-16], country_map.properties, first
# # publication dates
# # deprecated
# pub_date = custom, getPubDate
# pub_date_sort = custom, getPubDateSort
# pub_year_tisim = custom, getPubDateSliderVals
# # from 008 date 1
# publication_year_isi = custom, get008Date1(est)
# beginning_year_isi = custom, get008Date1(cdmu)
# earliest_year_isi = custom, get008Date1(ik)
# earliest_poss_year_isi = custom, get008Date1(q)
# release_year_isi = custom, get008Date1(p)
# reprint_year_isi = custom, get008Date1(r)
# other_year_isi = custom, getOtherYear
# # from 008 date 2
# ending_year_isi = custom, get008Date2(dm)
# latest_year_isi = custom, get008Date2(ik)
# latest_poss_year_isi = custom, get008Date2(q)
# production_year_isi = custom, get008Date2(p)
# original_year_isi = custom, get008Date2(r)
# copyright_year_isi = custom, get008Date2(t)
# # from 260c
# imprint_display = custom, getImprint
# 
# # Date field for new items feed
# date_cataloged = custom, getDateCataloged
# 
# language = custom, getLanguages, language_map.properties
# 
# # old format field, left for continuity in UI URLs for old formats
# format = custom, getOldFormats
# format_main_ssim = custom, getMainFormats
# format_physical_ssim = custom, getPhysicalFormats
# genre_ssim = custom, getAllGenres
# 
# db_az_subject = custom, getDbAZSubjects, db_subjects_map.properties
# 
# physical = 300abcefg
# vern_physical = custom, getLinkedField(300abcefg)
# 
# toc_search = 905art:505art
# vern_toc_search = custom, getLinkedField(505art)
# context_search = 518a
# vern_context_search = custom, getLinkedField(518a)
# summary_search = 920ab:520ab
# vern_summary_search = custom, getLinkedField(520ab)
# award_search = 986a:586a
# 
# # URL Fields
# url_fulltext = custom, getFullTextUrls
# url_suppl = custom, getSupplUrls
# url_sfx = 956u, (pattern_map.sfx)
# url_restricted = custom, getRestrictedUrls
# 
# # Standard Number Fields
# isbn_search = custom, getUserISBNs
# # Added fields for searching based upon list from Kay Teel in JIRA ticket INDEX-142
# issn_search = 022a:022l:022m:022y:022z:400x:410x:411x:440x:490x:510x:700x:710x:711x:730x:760x:762x:765x:767x:770x:771x:772x:773x:774x:775x:776x:777x:778x:779x:780x:781x:782x:783x:784x:785x:786x:787x:788x:789x:800x:810x:811x:830x, (pattern_map.issn)
# isbn_display = custom, getISBNs
# issn_display = custom, getISSNs
# lccn = 010a:010z, (pattern_map.lccn), first
# oclc = custom, getOCLCNums
# 
# # Call Number Fields
# callnum_facet_hsim = custom, getCallNumHierarchVals(|, callnumber_map)
# callnum_search = custom, getLocalCallNums
# shelfkey = custom, getShelfkeys
# reverse_shelfkey = custom, getReverseShelfkeys
# 
# # Location facet
# location_facet = custom, getLocationFacet
# 
# # Stanford student work facet
# stanford_work_facet_hsim = custom, getStanfordWorkFacet
# stanford_dept_sim = custom, getStanfordDeptFacet
# 
# # Item Info Fields (from 999 that aren't call number)
# barcode_search = 999i
# preferred_barcode = custom, getPreferredItemBarcode
# access_facet = custom, getAccessMethods
# building_facet = custom, getBuildings, library_map.properties
# item_display = customDeleteRecordIfFieldEmpty, getItemDisplay
# 
# on_order_library_ssim = custom, getOnOrderLibraries, library_on_order_map.properties
# 
# mhld_display = custom, getMhldDisplay
# bookplates_display = custom, getBookplatesDisplay
# fund_facet = custom, getFundFacet
# 
# # Digitized Items Fields
# managed_purl_urls = custom, getManagedPurls
# collection = custom, getCollectionDruids
# collection_with_title = custom, getCollectionsWithTitles
# set = custom, getSetDruids
# set_with_title = custom, getSetsWithTitles
# collection_type = custom, getCollectionType
# file_id = custom, getFileId
# 
# # INDEX-142 NOTE 3: Lane Medical adds (Print) or (Digital) descriptors to their ISSNs
# # so need to account for it in the pattern match below
# pattern_map.issn.pattern_0 = ^(\\d{4}-\\d{3}[X\\d]\\D*)$=>$1
# 
# pattern_map.lccn.pattern_0 = ^(([ a-z]{3}\\d{8})|([ a-z]{2}\\d{10})) ?|( /.*)?$=>$1
# 
# pattern_map.sfx.pattern_0 = ^(http://library.stanford.edu/sfx\\?(.+))=>$1
# pattern_map.sfx.pattern_1 = ^(http://caslon.stanford.edu:3210/sfxlcl3\\?(.+))=>$1
