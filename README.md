##Two vnetS with peering and FW

This project demonstrates creation of two separate vnetS with peering and FW.
When created, you can connect (by RDP from your machine) to a vm in vnet1 and from there to connect by RDP to the vm in vnet2.

##Content<br>
Each vnet project is a single independent project with:<br>
separate backend (state)
1 azurerm_resource_group<br>
1 azurerm_virtual_network<br>
1 azurerm_subnet<br>
2 azurerm_public_ip (one for the vm, second for the peering FW)<br>
1 azurerm_network_interface<br>
1 azurerm_network_security_group<br>
1 azurerm_network_interface_security_group_association<br>
1 azurerm_virtual_machine<br>

outputs:<br>
 rsc_grp_name<br>
 vnet_id<br>
 vnet_name<br>
 subnet_id<br>
 pub_ip_id<br>
 pub_ip_id_fw<br>

##Deployment

To deploy this project, follow the following steps:

cd vnet1<br>
terraform init<br>
terraform apply -auto-approve<br>

cd vnet2<br>
terraform init<br>
terraform apply -auto-approve<br>

cd Peering <br>
terraform init<br>
terraform apply -auto-approve<br>

