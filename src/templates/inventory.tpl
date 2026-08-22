%{~ for group in groups ~}

[${group.name}]

%{~ for vm in group.vms ~}
${vm.name} ansible_host=${vm.network_interface[0].nat_ip_address} fqdn=${vm.fqdn}

%{~ endfor ~}
%{~ endfor ~}
