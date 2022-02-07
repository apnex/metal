#!/bin/bash

nmcli connection import type openvpn file ../state/user1.ovpn
nmcli connection up user1
