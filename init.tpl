%EOS-STARTUP-CONFIG-START%
ip name-server 1.1.1.1
!
hostname {{ .hostname }} 
username {{ .username }} secret {{ .password }}
!
management api http-commands
 no shut
!
interface loopback 0
 ip address {{ .publicIP }}/32
%EOS-STARTUP-CONFIG-END%