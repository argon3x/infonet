#!/bin/bash
#
# colors
green="\e[01;32m"; yellow="\e[01;33m"; red="\e[01;31m"
blue="\e[01;34m"; purple="\e[01;35m"; end="\e[00m"

# Ctrl + c
CTRL_C (){
  echo -e "\n${red}>>> ${blue}Process Canceled${red} <<<${end}\n"
  tput cnorm
  exit 1
}
trap CTRL_C INT


# check depencencies
check_dependencies(){
  local path="/usr/bin"
  declare -i local count=0
  declare -a local dependencies=(ifconfig netstat)

  for i in ${dependencies[@]}; do
    `test -f ${path}/${i} > /dev/null 2>&1`
    if [[ $? -eq 0 ]]; then
      let count+=1
    fi
  done
  
  if [[ ${count} -eq ${#dependencies[@]} ]]; then
    return 0
  else
    return 1
  fi
}

# get_interface_details
get_interface_details(){
  local interface="$1"
  local mac_address=$(ifconfig ${interface} | grep -w "ether" | awk '{print $2}' FS=' ' 2>/dev/null)

  eval test -n ${mac_address}
  if [[ $? -eq 0 ]]; then
    echo -e "${purple}   > ${blue}Mac Address${red}: ${green}${mac_address:="${red}No Mac Address"}${end}"
  fi
}

# get connection details
get_connection_details(){
  local interface="${1}"
  declare -a local connection_details=($(ifconfig ${interface} | grep -w -E 'inet|netmask|broadcast' 2>/dev/null | awk '{print $2,$4,$6}' FS=' ' 2>/dev/null))

  echo -e "${purple}   > ${blue}IP Address${red}: ${green}${connection_details[0]:="${red}No IP Address"}${end}" 
  echo -e "${purple}   > ${blue}Netmask${red}: ${green}${connection_details[1]:="${red}No Netmask"}${end}" 
  echo -e "${purple}   > ${blue}Broadcast${red}: ${green}${connection_details[2]:="${red}No Broadcast"}${end}" 

  if [[ ${connection_details[2]} != "${red}No Broadcast" ]]; then
    local gateway_oct=$(route -n | awk '{print $2}' FS=' ' | grep -E "^[1-9]{3}")
    local gateway_dns=$(netstat -r | awk '{print $2}' FS=' ' | grep -E "[.][a-z]{2,3}$")
  fi
  echo -e "${purple}   > ${blue}Gateway${red}: ${green}${gateway_oct:="${red}No Gateway"}  ${gateway_dns}${end}" 
}

# get_details
get_details(){
  local interface="$1"

  for c in {1..44}; do echo -e "${purple}-${end}\c"; done
  echo -e "\n${blue}> ${yellow}Network Interface${red}: ${green}${interface}${end}"
  get_interface_details "${interface}"
  get_connection_details "${interface}"
  for c in {1..44}; do echo -e "${purple}-${end}\c"; done; echo

  # clean value from variable
  unset $interface
}

# check_interfaces
check_interfaces(){
  declare -i local count=1
  declare -a interfaces=($(ifconfig | grep -w 'flags' | awk '{print $1}' FS=':' 2>/dev/null))
  declare -a _interfaces_=(${interfaces[@]/'lo'})

  for i in ${_interfaces_[@]}; do
    if [[ ${#_interfaces_[@]} -eq 1 ]]; then
      get_details ${i}
      exit 0
    else
      echo -e "  ${purple}${count}${blue}) ${green}${i}${end}\c"
    fi
    let count+=1
  done; echo

  echo -en "${yellow}Select An Interface${red}: ${end}"; read answare
  if [[ 1 -le ${#_interfaces_[@]} ]]; then
    answare=$[${answare}-1]
    get_details "${_interfaces_[${answare}]}"
  else
    echo -e "\n${red}Option No Valid${end}\n"
  fi
}

eval check_dependencies
if [[ $? -eq 0 ]]; then
  clear
  check_interfaces
else
  echo -e "\n${red}<--- ${blue}Dependencies Error ${red}--->${end}\n"
  eval check_dependencies
fi
