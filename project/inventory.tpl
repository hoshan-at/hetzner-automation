[webservers]
%{ for server in webservers ~}
${server.name} ansible_host=${server.ipv4_address}
%{ endfor ~}

[all:vars]
ansible_user = root
