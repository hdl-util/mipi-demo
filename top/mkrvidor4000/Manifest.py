files = [
    "mkrvidor4000_top.sv",
    "arbiter.sv"
]

modules = {
    "git": [
        "git@github.com:hdl-util/hdmi.git::master",
        "git@github.com:hdl-util/sound.git::master",
        "git@github.com:hdl-util/vga-text-mode.git::master",
        "git@github.com:hdl-util/mipi-ccs.git::master",
        "git@github.com:hdl-util/mipi-csi-2.git::master",
        "git@github.com:hdl-util/sdram-controller.git::master",
        "git@github.com:hdl-util/clock-domain-crossing.git::master",
    ]
}

fetchto = "../../ip_cores"

