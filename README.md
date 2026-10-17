# OpenTitan

![OpenTitan logo](./doc/opentitan-logo.png)

## About the project

[OpenTitan](https://opentitan.org) is an open source silicon Root of Trust (RoT) project.
OpenTitan will make the silicon RoT design and implementation more transparent, trustworthy, and secure for enterprises, platform providers, and chip manufacturers.
OpenTitan is administered by [lowRISC CIC](https://www.lowrisc.org) as a collaborative project to produce high quality, open IP for instantiation as a full-featured product.
See the [OpenTitan site](https://opentitan.org) and [OpenTitan docs](https://opentitan.org/book/) for more information about the project.

## About this repository

This repository contains hardware, software and utilities written as part of the OpenTitan project.
It is structured as monolithic repository, or "monorepo", where all components live in one repository.
It exists to enable collaboration across partners participating in the OpenTitan project.

## Documentation

The project contains comprehensive documentation of all IPs and tools.
You can access it [online at opentitan.org/book/](https://opentitan.org/book/).

## How to contribute

Have a look at [CONTRIBUTING](CONTRIBUTING.md) and our [documentation on project organization and processes](./doc/project_governance/README.md) for guidelines on how to contribute code to this repository.

## Licensing

Unless otherwise noted, everything in this repository is covered by the Apache License, Version 2.0 (see [LICENSE](https://github.com/lowRISC/opentitan/blob/master/LICENSE) for full text).

## Simulating with iSim

[iSim](https://tn-si.com) (True North Silicon) runs this design through FuseSoC
with its `.core` files untouched. FuseSoC selects a simulator through
**edalize**; iSim's backend is `isimtn` (edalize's own `isim` is the Xilinx ISE
Simulator) and lives in True North Silicon's edalize fork. Two installs, in this
order, into the Python environment your `fusesoc` runs from:

    pip install fusesoc
    pip install --force-reinstall git+https://github.com/Datum-Technology-Corporation/edalize.git

(the second replaces the edalize FuseSoC pulled in with the fork; pip warns
that fusesoc pins `edalize>=0.4.1`, which the fork's development version
number does not satisfy -- the warning is all that happens. Keep the two
installs separate: one `pip install fusesoc git+...` resolves that pin by
downgrading fusesoc.) `isim`, `isim-vlog`, `isim-vcom` and `isim-elab` must
be on `PATH`.

Then, from this checkout, for a single IP:

    fusesoc --cores-root . run --tool=isimtn --mapping=lowrisc:prim_generic:all:0.1 --setup --build lowrisc:ip:hmac

The mapping is required: the `prim` library is virtual, and without it FuseSoC
binds an implementation at random (ASAP7, Xilinx, ...).
