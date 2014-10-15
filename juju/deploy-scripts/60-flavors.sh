# Create flavors for tempest to use.  It's important that these
# flavors specify 0 as the disk size; that lets the resize tests work.
. ~/admin-openrc
add-subst FLAVOR $(nova flavor-create m1.nano auto 128 0 1 | get-id)
add-subst FLAVOR_ALT $(nova flavor-create m1.micro 84 192 0 1 | get-id)
