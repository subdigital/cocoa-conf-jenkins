#! /bin/sh

# Takes a provisioning profile and installs it into the system path.
# This requires poking inside the provisioning profile and searching for the
# UUID present at the end of the file.

set -e

if [[ -z "$1" ]]
then
  echo "USAGE: install_provisioning_profile PROVISIONING_FILE"
  exit 1
fi

if [[ ! -f $1 ]]
then
  echo "The file $1 does not exist"
  exit 1
fi

mobile_provisioning_file=$1
echo "Processing $mobile_provisioning_file"

uuid=`grep "UUID" -A1 -a "$mobile_provisioning_file" | grep -o "[-A-Z0-9]\{36\}"`
echo "uuid is $uuid"

if [[ -z "$uuid" ]]
then
  echo "UUID could not be found in $mobile_provisioning_file"
  exit 1
fi

destination="$HOME/Library/MobileDevice/Provisioning Profiles/$uuid.mobileprovision"
cp $mobile_provisioning_file "$destination"
echo "Installed to $destination"
