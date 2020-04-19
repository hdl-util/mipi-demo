target = "altera"
action = "synthesis"

syn_family = "CYCLONE 10 LP"
syn_device = "10CL016Y"
syn_grade = "C8G"
syn_package = "U256"
syn_top = "mkrvidor4000_top"
syn_project = "mipi-demo"
syn_tool = "quartus"

quartus_preflow = "../../top/mkrvidor4000/pinout.tcl"
quartus_postmodule = "../../top/mkrvidor4000/module.tcl"

modules = {
  "local" : [
    "../../top/mkrvidor4000",
    "../../pll"
  ],
}

