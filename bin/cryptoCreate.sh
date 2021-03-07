#!/bin/bash
source "$(dirname $0)/luks.sh"

nameVol "create";
nameSize;
ddZero;
encryptCon;
encryptOpen;
mkfsFormat;
mountDir;
volPerm
