###
### awsp - aws profile manager & sync
###

PROFILE_SOURCE="$HOME/.aws/source_current_profile"

function awsp () {

  IFS=$'\n' local valid_profiles=( $(sed -nr 's/\[profile ([a-zA-Z0-9_-]+)\]/\1/p' "$HOME/.aws/config" ) )
  
  usage (){
    echo "Usage: awsp (-l/--list) [(-u/--unset) | PROFILE]"
    echo
    echo "An AWS-CLI profile environment variable manager & synchronizer"
    echo
    echo "Options:"
    echo "  -c, --current-profile  Prints the currently selected profile"
    echo "  -l, --list             Lists the available profiles from ~/.aws/config"
    echo "  -u, --unset            Unsets the AWS_PROFILE environment variable,"
    echo "                          selected by default if no PROFILE is supplied"
    echo
    echo "Arguments:"
    echo "  PROFILE        Name of the profile to set, sourced from ~/.aws/config"
    echo
  }

  if [[ "$#" -gt 1 ]]; then
    echo "error: incorrect number of arguments"
    echo
    usage
    return
  fi

  list_profiles() {
    printf '%s\n' "${valid_profiles[@]}"
  }

  validate_profile() {
    if ! (( ${valid_profiles[(Ie)$profile]} )); then
      echo "error: invalid profile name"
      echo
      usage
      return 1
    fi
  }

  get_profile() {
    echo "$AWS_PROFILE"
  }
  set_profile() {
    touch "$PROFILE_SOURCE" && dotenv -f "$PROFILE_SOURCE" set AWS_PROFILE="$profile"
    echo "using profile '$profile'"
    #source "$PROFILE_SOURCE"
    #export AWS_PROFILE="$profile"
  }

  unset_profile() {
    touch "$PROFILE_SOURCE" && dotenv -f "$PROFILE_SOURCE" unset AWS_PROFILE
    echo "unset profile"
  }

  case "$1" in
    -c|--current-profile)
      get_profile
      return
    ;;
    -l|--list)
      list_profiles
      return
    ;;
    -h|--help)
      usage
      return
    ;;
    -u|--unset|"")
      unset_profile
      return
    ;;
    *)
      local profile="$1"
      if validate_profile ; then
        set_profile
      fi
      return
    ;;
  esac
}
# awsp completion
function _awsp() { local -a arguments ; IFS=$'\n' arguments=( --current-profile --list --unset $(sed -nr 's/\[profile ([a-zA-Z0-9_-]+)\]/\1/p' ~/.aws/config ) ) ; _describe 'values' arguments ; }
compdef _awsp awsp
# precmd_func
function source_aws_profile() { [[ -s "$PROFILE_SOURCE" ]] && { source "$PROFILE_SOURCE"; export AWS_PROFILE="$AWS_PROFILE"; } || unset AWS_PROFILE; }
###
### awsp - END
###
