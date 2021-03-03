#!/bin/bash
source "$(dirname $0)/luks.sh"

nameVol;
#nameKey;
#nameMount;
nameSize;
ddZero;
#ddRandom;
encryptCon;
encryptOpen;
mkfsFormat;
mountDir;
volPerm
