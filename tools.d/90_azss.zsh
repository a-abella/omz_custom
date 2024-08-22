###
### azss - azure subscription manager
###

function azss () {

  local subscription_file="$HOME/.azure/azureProfile.json"
  IFS=$'\n' local valid_subscriptions=( $( jq -r '.subscriptions[].name' "$subscription_file" ) )
  local null_subscription_name="none"
  
  usage (){
    echo "Usage: azss (-l/--list) [(-u/--unset) | SUBSCRIPTION]"
    echo
    echo "An Azure-CLI subscription manager"
    echo
    echo "Options:"
    echo "  -c, --current-subscription"
    echo "                 Prints the currently selected subscription name"
    echo "  -l, --list     Lists the available subscriptions from"
    echo "                   ~/.azure/azureProfile.json"
    echo "  -u, --unset    Sets the active subscription to a null entry, and"
    echo "                   inserts the null entry to azureProfile.json if one"
    echo "                   is not found."
    echo "                   Selected by default if no SUBSCRIPTION is supplied"
    echo
    echo "Arguments:"
    echo "  SUBSCRIPTION     Name of the subscription to set, sourced from"
    echo "                     ~/.azure/azureProfile.json"
    echo
  }

  if [[ "$#" -gt 1 ]]; then
    echo "error: incorrect number of arguments"
    echo
    usage
    return
  fi

  list_subscriptions() {
    printf '%s\n' "${valid_subscriptions[@]}"
  }

  validate_subscription() {
    if ! (( ${valid_subscriptions[(Ie)$subscription]} )); then
      echo "error: invalid subscription name"
      echo
      usage
      return 1
    fi
  }

  get_subscription() {
    jq -r '.subscriptions[] | select(.isDefault==true) | if .name == "none" then empty else .name end' "$subscription_file" 
  }

  set_subscription() {
    az account set --subscription "$subscription"
    echo "using subscription '$subscription'"
  }
  
  inject_null_subcription() {
    local tmp_file="$(mktemp -p "$(dirname "$subscription_file")")"
    local null_subscription="{\"id\":\"00000000-0000-0000-0000-000000000000\",\"name\":\"$null_subscription_name\",\"state\":\"Enabled\",\"isDefault\":false,\"environmentName\":\"AzureCloud\"}"
    jq -c ".subscriptions += [$null_subscription]" "$subscription_file" > "$tmp_file"
    mv "$tmp_file" "$subscription_file"
  }

  unset_subscription() {
    az account set --subscription none
    echo "unset subscription"
  }

  case "$1" in
    -c|--current-subscription)
      get_subscription
      return
    ;;
    -l|--list)
      list_subscriptions
      return
    ;;
    -h|--help)
      usage
      return
    ;;
    -u|--unset|"")
      (( ! ${valid_subscriptions[(Ie)$null_subscription_name]} )) && inject_null_subcription
      unset_subscription
      return
    ;;
    *)
      local subscription="$1"
      if validate_subscription ; then
        set_subscription
      fi
      return
    ;;
  esac
}
# azss completion
function _azss() { local -a arguments ; IFS=$'\n' arguments=( --current-subscription --list --unset $( jq -r '.subscriptions[].name' "$HOME/.azure/azureProfile.json" ) ) ; _describe 'values' arguments ; }
compdef _azss azss
###
### azss - END
###
