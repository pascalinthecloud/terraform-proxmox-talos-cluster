---
title: Upgrade talos
description: A guide for upgrading talos cluster.
---
First we need get the schematic id from the outputs and use that for upgrading the cluster in order to keep the extensions. 
```bash
talosctl upgrade --image factory.talos.dev/installer/<SCHEMATIC_ID>:v1.9.3 --preserve
```
The preserve option is only needed when wanting to keep files/directories on Talos nodes (for example when using Longhorn/Rook...)