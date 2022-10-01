#!/bin/bash

set -e

for extension in librejs https-everywhere librejs-usps-compatibility submit-me disable-polymer-youtube privacy-redirect javascript-restrictor librifyjs-libgen-me-repack; do

  rm -rf /tmp/update-extension
  mkdir /tmp/update-extension
  (cd /tmp/update-extension
   wget -q -O extension.xpi  https://addons.mozilla.org/firefox/downloads/latest/$extension/addon-$extension-latest.xpi
   unzip -q extension.xpi
   rm extension.xpi)

  if [ -f /tmp/update-extension/install.rdf ]; then
    ID=$(grep em:id /tmp/update-extension/install.rdf |sed 's/.*<em:id>//; s/<.*//' |head -n1)
  fi
  if [ -f /tmp/update-extension/manifest.json ]; then
    ID=$(grep '"id":' /tmp/update-extension/manifest.json |head -n1|cut -d \" -f 4)
  fi

  [ $extension = "use-google-drive-with-librejs" ] && ID="google_drive@0xbeef.coffee"
  [ -z $ID ] && ID=$extension"@extension"

  rm -rf extensions/$ID
  mv /tmp/update-extension extensions/$ID

  echo updated $extension
done

sed '/autoUpdateRulesets/s/true/false/' -i extensions/https-everywhere@eff.org/pages/options/ux.js extensions/https-everywhere@eff.org/background-scripts/update.js

for ID in viewtube@extension disable-polymer-youtube@extension; do
  sed 's/^{/{\n  "applications": { "gecko": { "id": "'$ID'" } },/' -i extensions/$ID/manifest.json
done

find extensions -name cose.manifest -delete
find extensions -name cose.sig -delete
