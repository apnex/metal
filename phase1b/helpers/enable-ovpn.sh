#!/bin/bash

nmcli connection import type openvpn file ../state/user1.ovpn
nmcli connection modify user1 ipv4.never-default yes
nmcli connection up user1
