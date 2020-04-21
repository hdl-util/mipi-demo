files = [
    "mkrvidor4000_top.sv",
    "MIPI_RX_ST.v",
    "arbiter.sv"
]

modules = {
    "git": [
        "git@github.com:hdl-util/hdmi.git::master",
        "git@github.com:hdl-util/sound.git::master",
        "git@github.com:hdl-util/vga-text-mode.git::master",
        "git@github.com:hdl-util/mipi-ccs.git::master",
        "git@github.com:hdl-util/mipi-csi-2.git::master",
        "git@github.com:hdl-util/as4c4m16sa.git::master",
    ]
}

fetchto = "../../ip_cores"

