verdiWindowResize -win $_vdCoverage_1 "1281" "31" "1278" "1360"
gui_set_pref_value -category {coveragesetting} -key {geninfodumping} -value 1
gui_exclusion -set_force true
verdiSetFont  -font  {DejaVu Sans}  -size  11
verdiSetFont -font "DejaVu Sans" -size "11"
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
verdiSetActWin -dock widgetDock_<CovDetail>
gui_open_cov  -hier coverage.vdb -testdir  {coverage.vdb} -test { coverage/sim1 } -merge MergedTest -db_max_tests 10 -sdc_level 1 -fsm transition
gui_covtable_show -show  { Function Groups } -id  CoverageTable.1  -test  MergedTest
verdiSetActWin -dock widgetDock_<Summary>
gui_list_select -id CoverageTable.1 -list covtblFGroupsList { {/$unit::apb_coverage::apb_cg}   }
gui_list_expand -id  CoverageTable.1   -list {covtblFGroupsList} {/$unit::apb_coverage::apb_cg}
gui_list_expand -id CoverageTable.1   {/$unit::apb_coverage::apb_cg}
gui_list_action -id  CoverageTable.1 -list {covtblFGroupsList} {/$unit::apb_coverage::apb_cg}  -column {Group} 
gui_list_select -id CovDetail.1 -list covergroup { {$unit::apb_coverage::apb_cg.cp_addr}   } -type { {Cover Group}  }
verdiSetActWin -dock widgetDock_<CovDetail>
vdCovExit -noprompt
