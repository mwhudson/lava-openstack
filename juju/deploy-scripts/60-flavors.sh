# Create flavors for tempest to use.  It's important that these
# flavors specify 0 as the disk size; that lets the resize tests work.
. ~/admin-openrc
tempest-set compute flavor_ref $(nova flavor-create m1.nano auto 128 0 1 | awk 'NR==4 { print $2 }')
tempest-set compute flavor_ref_alt $(nova flavor-create m1.micro auto 192 0 1 | awk 'NR==4 { print $2 }')
