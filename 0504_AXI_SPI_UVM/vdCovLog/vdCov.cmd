verdiWindowResize -win $_vdCoverage_1 "830" "370" "1024" "709"
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
verdiWindowResize -win $_vdCoverage_1 "830" "370" "1024" "709"
gui_covtable_show -show  { Module List } -id  CoverageTable.1
gui_covtable_show -show  { Function Groups } -id  CoverageTable.1
verdiSetActWin -dock widgetDock_<Summary>
gui_covtable_show -show  { Asserts } -id  CoverageTable.1
gui_covtable_show -show  { Function Groups } -id  CoverageTable.1
gui_covtable_show -show  { Module List } -id  CoverageTable.1
vdCovExit -noprompt
