verdiWindowResize -win $_vdCoverage_1 "0" "23" "2560" "1369"
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
gui_set_pref_value -category {ColumnCfg} -key {covtblAssertList_Assert} -value {true}
gui_set_pref_value -category {ColumnCfg} -key {covtblAssertList_Match} -value {false}
gui_set_pref_value -category {ColumnCfg} -key {covtblAssertList_Success} -value {false}
gui_covtable_show -show  { Function Groups } -id  CoverageTable.1  -test  MergedTest
verdiSetActWin -dock widgetDock_<Summary>
gui_list_select -id CoverageTable.1 -list covtblFGroupsList { {/$unit::I2C_coverage::I2C_cg}   }
gui_list_expand -id  CoverageTable.1   -list {covtblFGroupsList} {/$unit::I2C_coverage::I2C_cg}
gui_list_expand -id CoverageTable.1   {/$unit::I2C_coverage::I2C_cg}
gui_list_action -id  CoverageTable.1 -list {covtblFGroupsList} {/$unit::I2C_coverage::I2C_cg}  -column {Group} 
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_m_rx_data}  {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}   } -type { {Cover Group} {Cover Group}  }
verdiSetActWin -dock widgetDock_<CovDetail>
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}  {$unit::I2C_coverage::I2C_cg.cp_rw}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_rw}  {$unit::I2C_coverage::I2C_cg.cx_rw_data}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cx_rw_data}  {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}  {$unit::I2C_coverage::I2C_cg.cp_m_rx_data}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_m_rx_data}  {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}  {$unit::I2C_coverage::I2C_cg.cx_rw_data}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cx_rw_data}  {$unit::I2C_coverage::I2C_cg.cp_m_rx_data}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_m_rx_data}  {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}   } -type { {Cover Group} {Cover Group}  }
gui_list_select -id CovDetail.1 -list covergroup { {$unit::I2C_coverage::I2C_cg.cp_m_tx_data}  {$unit::I2C_coverage::I2C_cg.cp_rw}   } -type { {Cover Group} {Cover Group}  }
vdCovExit -noprompt
