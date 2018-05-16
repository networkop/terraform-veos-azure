
%EOS-STARTUP-CONFIG-START%
ip name-server 1.1.1.1
!
vrf definition VPN
!
ip routing
ip routing vrf VPN
!
hostname ${ hostname } 
username ${ username } secret ${ password }
aaa root secret ${ password }
!
management api http-commands
 no shut
!
interface loopback 0
 ip address ${ publicIP }/32
!
interface Ethernet1
   description "Public-facing"
   no switchport
   ip address ${ outside_ip } ${ outside_netmask }
!
interface Ethernet2
   description "User-facing"
   no switchport
   vrf forwarding VPN
   ip address ${ inside_ip } ${ inside_netmask }
!
ip route 0.0.0.0/0 ${ outside_gw } name PUBLIC-DEFAULT
!
%EOS-STARTUP-CONFIG-END%