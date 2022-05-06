zvpn(){
OPTIONS=("exit" "start" "status" "restart" "stop" "stats" "config-import" "config-list" "config-delete" "help")

echo ""
echo ""
echo "================================Running sessions================================="
openvpn3 sessions-list
echo "=================================================================================="

echo ""
echo ""
PS3="Select option (number): "
select opt in "${OPTIONS[@]}"
  do
   case $opt in
    "exit")
      echo "Exiting zvpn cmd"
      break
      ;;
    "start")
      zvalidate_execute
      vpn=$(value_if_null "$1"  zvpn_select)
      openvpn3 session-start --config "$vpn"
      break
      ;;
    "stop")
      zvalidate_execute
      vpn=$(value_if_null "$1"  zvpn_select)
      openvpn3 session-manage --config "$vpn" --disconnect
      break
      ;;
    "restart")
      zvalidate_execute
      vpn=$(value_if_null "$1"  zvpn_select)
      openvpn3 session-manage --config "$vpn" --restart
      break
      ;;
    "status")
      openvpn3 sessions-list
      break
      ;;
    "stats")
      zvalidate_execute
      vpn=$(value_if_null "$1"  zvpn_select)
      openvpn3 session-stats --config "$vpn"
      break
      ;;
    "config-import")
      zvpn_import
      break
      ;;
    "config-list")
      echo ""
      echo "Available configurations:"
      openvpn3 configs-list | awk '{print $1}'  | tr -d '-'| grep -o '\S\+' | awk 'NR % 3 == 0 && NR > 3'
      break
      ;;
    "config-delete")
      zvalidate_execute
      vpn=$(value_if_null "$1"  zvpn_select)
      openvpn3 config-remove --config "$vpn"
      break
      ;;
    *)
      echo ""
      echo "To start with zvpn, locate an ovpn file and import configuration with zvpn import command."
      echo ""
      echo "Available commands (mandatory attributes are marked with *):"
      echo "  start           - Starts a vpn profile. Usage: zvpn <profile name> -> select option 2"
      echo "  status          - Status of a vpn profile. Usage: zvpn <profile name> -> select option 3"
      echo "  restart         - Restart a vpn profile. Usage: zvpn <profile name> -> select option 4"
      echo "  stop            - Stop a vpn profile. Usage: zvpn <profile name> -> select option 5"
      echo "  stats           - Statistics of a vpn profile. Usage: zvpn <profile name> -> select option 6"
      echo "  config-import   - Import a ovpn config. Usage: zvpn <Location of ovpn file> <profile name> -> select option 7"
      echo "  config-list     - List all imported config. Usage: zvpn -> select option 8"
      echo "  config-delete   - Delete imported config Usage: zvpn <profile name> -> select option 9"
      echo "  help            - Help. Usage: zvpn -> select option 10"
      echo ""
      echo "* Note: If optional parameters are not given, options menu will ask for the missing parameters"
      break
      ;;
  esac
done

}


value_if_null(){
  if [[ "$1" == "" ]]; then
    eval "$2"
  else
    echo "$1"
  fi
}

zvalidate_execute(){
  test="$(openvpn3 configs-list | awk '{print $1}'  | tr -d '-'| grep -o '\S\+' | awk 'NR % 3 == 0 && NR > 3'|wc -l)"
  if [[ "$test" == "0" ]];then
    echo ""
    echo "ERROR: No vpn configuration found"
    echo "  => Import ovpn file using zvpn config-import command"
    break;
  fi
}

zvpn_import(){
  printf '%s ' 'Location of ovpn file(full path): '
  read location
  printf '%s ' 'Name of the profile: '
  read profile
  if [[ "$profile" != "" ]] && [[ "$location" != "" ]]; then
    openvpn3 config-import --config "$location" --name "$profile" --persistent
  fi
}

zvpn_select(){
  BUCKETS=()
  while IFS= read -r entry; do
      BUCKETS+=("$entry")
  done <<<"$(openvpn3 configs-list | awk '{print $1}'  | tr -d '-'| grep -o '\S\+' | awk 'NR % 3 == 0 && NR > 3')"

  if [[ "${#BUCKETS[@]}" == "1" ]]; then
    echo "${BUCKETS[1]}"
    break
  fi

  PS3="Select VPN profile (number): "
  select opt in "${BUCKETS[@]}"
    do
      case $opt in
      "Exit")
        break
        ;;
      *)
        echo $opt
        break
        ;;
    esac
  done

}
