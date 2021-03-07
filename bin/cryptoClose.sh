#!/bin/bash
source "$(dirname $0)/luks.sh"

nameVol "close";
umountDir;
encryptClose;
