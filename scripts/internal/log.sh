#!/bin/sh

orange() {
	orange=33
	echo -e "\033[${orange}m$@\033[m"
}

green() {
	green=32
	echo -e "\033[${green}m$@\033[m"
}
red() {
	red=31
	echo -e "\033[${red}m$@\033[m"
}
