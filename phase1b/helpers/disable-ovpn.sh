#!/bin/bash

nmcli connection down user1
sleep 3
nmcli connection delete user1
