#!/usr/bin/env bash
echo "Building monkey-ops docker image"


# oc new-build  --strategy docker --binary --name="monkey-ops"

 oc start-build monkey-ops --from-dir=. --follow --wait