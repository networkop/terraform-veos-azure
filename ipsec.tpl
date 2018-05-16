!
vrf definition VPN
!
ip routing
ip routing vrf VPN
!
ip security
   ike policy IKE-PROPOSAL-AES-256-CBC-GR20
      ike-lifetime 24
      encryption aes256
      dh-group 20
      local-id ${ publicIP }
   !
   sa policy IPSEC-POLICY-AES-256-CBC-GR20
      pfs dh-group 20
   !
   profile IPSEC-PROFILE-AES-256-CBC-GR20
      ike-policy IKE-PROPOSAL-AES-256-CBC-GR20 
      sa-policy IPSEC-POLICY-AES-256-CBC-GR20 
      connection start
      shared-key ${ ipsec_psk }
!
ip route vrf VPN ${ local_subnet_1 } ${ inside_gw } tag 100 name USER-SUBNET-1
!
interface Tunnel0
   description "fn=DIC dd=<crtj-lab1-0001> di=<ms-1/3/0.1000>"
   mtu 1428
   vrf forwarding VPN
   ip address ${ local_tunnel_ip }
   tunnel mode ipsec
   tunnel source ${ tunnel_source }
   tunnel destination ${ tunnel_dest }
   tunnel mss ceiling 1380
   tunnel ipsec profile IPSEC-PROFILE-AES-256-CBC-GR20
! 
route-map PL-STATIC permit 10
   match tag 100
   set origin igp
   set community ${ local_asn }:${ local_community }
!
router bgp ${ local_asn }
   vrf VPN
      bgp log-neighbor-changes
      maximum-paths 4 ecmp 16
      neighbor ${ peer_tunnel_ip } remote-as ${ peer_asn }
      neighbor ${ peer_tunnel_ip }  description ${ peer_desc }
      neighbor ${ peer_tunnel_ip }  timers 4 12
      neighbor ${ peer_tunnel_ip }  password 0 ${ peer_key }
      neighbor ${ peer_tunnel_ip }  send-community
      neighbor ${ peer_tunnel_ip }  maximum-routes 12000 
      redistribute static route-map PL-STATIC
!