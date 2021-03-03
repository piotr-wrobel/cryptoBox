#!/bin/bash
source "$(dirname $0)/luks.sh"

nameVol;
encryptOpen;
mountDir;
