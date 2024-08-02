###
### awsp - aws profile manager
###

PROFILE_SOURCE="$HOME/.aws/source_current_profile"

function awsp () {

  local valid_profiles=( $(sed -nr 's/\[profile ([a-zA-Z0-9_-]+)\]/\1/p' "$HOME/.aws/config" ) )
  
  usage (){
    echo "Usage: awsp (-l/--list) [(-u/--unset) | PROFILE]"
    echo
    echo "An AWS-CLI profile environment variable manager"
    echo
    echo "Options:"
    echo "  -u, --unset    Unsets the AWS_PROFILE environment variable,"
    echo "                   selected by default if no PROFILE is supplied"
    echo
    echo "Arguments:"
    echo "  PROFILE        Name of the profile to set, sourced from .aws/config"
    echo
    echo "Valid PROFILE names:"
    printf '  - %s\n' "${valid_profiles[@]}"
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
function _awsp() { local -a arguments ; arguments=( --list --unset $(sed -nr 's/\[profile ([a-zA-Z0-9_-]+)\]/\1/p' ~/.aws/config ) ) ; _describe 'values' arguments ; }
compdef _awsp awsp
# precmd_func
function source_aws_profile() { [[ -s "$PROFILE_SOURCE" ]] && source "$PROFILE_SOURCE" || unset AWS_PROFILE; }
###
### awsp - END
###
