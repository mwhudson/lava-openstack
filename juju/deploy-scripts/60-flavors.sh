. ~/admin-openrc
add-subst FLAVOR $(nova flavor-create m1.nano auto 128 0 1 | get-id)
add-subst FLAVOR_ALT $(nova flavor-create m1.micro 84 192 0 1 | get-id)
