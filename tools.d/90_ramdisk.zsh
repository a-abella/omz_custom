###
### ramdisk - a manager for macos ram disks/tmpfs volumes
###

function ramdisk () {
  local RAMDISK_STATE="$HOME/.config/ramdisk.state"
  [[ ! -e "$RAMDISK_STATE" ]] && touch "$RAMDISK_STATE"
  
  local RAMDISK_VOL_NAME
  local RAMDISK_LINK_PATH
  local RAMDISK_SIZE_MB
  
  usage_root_cmd () {
    echo "Usage: ramdisk [ up | down | list | prune ]"
    echo
    echo "A ram-disk manager for MacOS"
    echo
    echo "Arguments:"
    echo "  up          Create and symlink a ramdisk volume to your chosen path"
    echo "  down        Remove and destroy the ramdisk and related symlinks"
    echo "  list        List stored ramdisk configurations"
    echo "  prune       Remove stored configs associated with missing ramdisks"
    echo
  }
  
  case "$1" in
      up)
          shift
          
          usage_up_cmd () {
            echo "Usage: ramdisk up ( --name=NAME | --size-mb=SIZE | --link-path=PATH )"
            echo
            echo "Initialize a ramdisk and set a link to the generated volume"
            echo
            echo "Options:"
            echo "  --name       The name for the ramdisk volume,"
            echo "                default: ramdisk"
            echo "  --size-mb    The amount of MB to allocate to the ramdisk,"
            echo "                default: 256"
            echo "  --link-path  The path to symlink to the ramdisk volume,"
            echo "                default: \$HOME/[--name arg]"
            echo
          }
          
          local -A zopts
          if ! zparseopts -F -D -E -A zopts -- h=help -help -name: -size-mb: -link-path: 2>/dev/null ; then
            usage_up_cmd
            return 1
          fi
          [[ -v zopts[-h] || -v zopts[--help] ]] && usage_up_cmd && return
          
          RAMDISK_VOL_NAME="${zopts[--name]:-ramdisk}"
          RAMDISK_SIZE_MB="${zopts[--size-mb]:-256}"
          RAMDISK_LINK_PATH="${zopts[--link-path]:-$HOME/$RAMDISK_VOL_NAME}"
          
          validate_name () {
            if [[ -n "$(dotenv -f "$RAMDISK_STATE" get "$RAMDISK_VOL_NAME")" ]]; then
              echo "ramdisk: error: a ramdisk configuration matching name '$RAMDISK_VOL_NAME' already exists in $RAMDISK_STATE" >&2
              return 1
            fi
            if mount | grep -wq "/Volumes/$RAMDISK_VOL_NAME" ; then
              echo "ramdisk: error: a mounted volume with name $RAMDISK_VOL_NAME already exits" >&2
              return 1
            fi
          }
          
          validate_size () {
            if [[ "$1" != <-> ]]; then
              echo "ramdisk: error: size_mb argument number be an integer" >&2
              return 1
            fi
            
            local req_mb="$1"
            local system_mem_mb
            system_mem_mb="$(( $(sysctl -n hw.memsize) / ( 1024**2 ) ))"
            
            if [[ "$(bc -l <<< "($req_mb / $system_mem_mb) > 0.333")" -ne 0 ]]; then
                echo "ramdisk: error: supplied size_mb value '$req_mb' exceeds 1/3 of system memory" >&2
                return 1
            fi
          }
          
          validate_link () {
            if [[ -L "$1" ]]; then
              if [[ "$(readlink -f "$1")" != "/Volumes/$RAMDISK_VOL_NAME" ]]; then
                  echo "ramdisk: error: would clobber existing symlink '$1 -> $(readlink -f "$1")'" >&2
                  return 1
              fi
              create_link=0
              return 0
            elif [[ -e "$1" ]]; then
              echo "ramdisk: error: cannot create symlink at '$RAMDISK_LINK_PATH'; file aready exists" >&2
              return 1
            fi
          }
          
          if ! validate_name "$RAMDISK_VOL_NAME"; then return 1; fi
          local create_link=1
          if ! validate_link "$RAMDISK_LINK_PATH"; then return 1; fi
          if ! validate_size "$RAMDISK_SIZE_MB"; then return 1 ; fi
          local size_blocks=$(( 2048 * $RAMDISK_SIZE_MB ))  
          
          diskutil erasevolume APFS "$RAMDISK_VOL_NAME" $(hdiutil attach -nobrowse -nomount ram://${size_blocks})
          echo "ramdisk created"
          
          if [[ ! -d "/Volumes/$RAMDISK_VOL_NAME" ]]; then
            echo "ramdisk: error: did not find expected ramdisk volume at /Volumes/$RAMDISK_VOL_NAME" >&2
            return 1
          fi
          if [[ $create_link -ne 0 ]]; then
            ln -s "/Volumes/$RAMDISK_VOL_NAME" "$RAMDISK_LINK_PATH"
            dotenv -f "$RAMDISK_STATE" set "$RAMDISK_VOL_NAME"="$RAMDISK_SIZE_MB:$RAMDISK_LINK_PATH"  
            echo "ramdisk linked to $RAMDISK_LINK_PATH"
          fi
      ;;
      down)
        shift
        
        usage_down_cmd () {
          echo "Usage: ramdisk down ( --name=NAME | --link-path=PATH )"
          echo
          echo "Tear down a ramdisk volume and clean up managed symlinks"
          echo
          echo "Options:"
          echo "  --name       The name of the existing ramdisk volume,"
          echo "                default: ramdisk"
          echo
        }
        
          local -A zopts
          if ! zparseopts -F -D -E -A zopts -- h=help -help -name: 2>/dev/null ; then
            usage_down_cmd
            return 1
          fi
          [[ -v zopts[-h] || -v zopts[--help] ]] && usage_down_cmd && return
          
          RAMDISK_VOL_NAME="${zopts[--name]:-ramdisk}"
          RAMDISK_LINK_PATH="$(dotenv -f "$RAMDISK_STATE" get "$RAMDISK_VOL_NAME" | awk -F':' '{print $2}')"
          
          if [[ -z "$RAMDISK_LINK_PATH" ]]; then
            echo "ramdisk: error: no ramdisk configuration matching name '$RAMDISK_VOL_NAME' found in $RAMDISK_STATE" >&2
            return 1
          fi
          local disk_id
          disk_id="$(mount | grep -w "/Volumes/$RAMDISK_VOL_NAME" | awk '{print $1}')"
          if [[ -z "$disk_id" ]]; then
              echo "ramdisk: error: no ramdisk volume was found at /Volumes/$RAMDISK_VOL_NAME" >&2
              return 1
          fi
          
          if [[ -e "$RAMDISK_LINK_PATH" ]]; then
              if [[ -L "$RAMDISK_LINK_PATH" ]]; then
                  if [[ "$(readlink -f "$RAMDISK_LINK_PATH")" != "/Volumes/$RAMDISK_VOL_NAME" ]]; then
                      echo "ramdisk: warning: not removing unexpected ramdisk symlink '$RAMDISK_LINK_PATH -> $(readlink -f "$RAMDISK_LINK_PATH")'" >&2
                  else
                      rm "$RAMDISK_LINK_PATH"
                      echo "ramdisk link removed"
                  fi
              else
                  echo "ramdisk: warning: not removing unexpected file at '$RAMDISK_LINK_PATH'"
              fi
          fi
          hdiutil unmount "$disk_id"
          hdiutil detach "$disk_id"
          dotenv -f "$RAMDISK_STATE" unset "$RAMDISK_VOL_NAME"
          echo "ramdisk destroyed"
      ;;
      list)
        {
          echo "NAME:SIZE_MB:LINK_PATH"
          dotenv --file "$RAMDISK_STATE" list | awk -F ':|=' '{print $1 ":" $2 ":" $3}'
        } | column -s':' -t
      ;;
      prune)
        while read -r entry; do
          IFS=':' read -r RAMDISK_VOL_NAME RAMDISK_SIZE_MB RAMDISK_LINK_PATH <<< "$(echo "$entry" | awk -F':|=' '{print $1 ":" $2 ":" $3}')"
          if ! hdiutil info | grep -wq "/Volumes/$RAMDISK_VOL_NAME" ; then
            if [[ -L "$RAMDISK_LINK_PATH" ]]; then
              rm "$RAMDISK_LINK_PATH"
            fi
            dotenv --file "$RAMDISK_STATE" unset "$RAMDISK_VOL_NAME"
            echo "pruned absent ramdisk '$RAMDISK_VOL_NAME' with link $RAMDISK_LINK_PATH"
          fi
        done <<< "$(dotenv --file "$RAMDISK_STATE" list)"
        :
      ;;
      *)
          usage_root_cmd
          if [[ ! "$1" =~ ^(-h|--help)$ ]]; then
            return 1
          fi
  esac
}

compdef _ramdisk ramdisk
_ramdisk () {
    local state
    local RAMDISK_STATE="$HOME/.config/ramdisk.state"
    _arguments -s \
      '1: :((up down list prune --help))' \
      '*::arg:->args' \
    && return 0
    
    case $state in
      (args)
        case $words[1] in
          down)
            _arguments \
              '--name::name:->name' \
              '--help:help' \
              && return 0
              
              if [[ "${words[2]}" == "--name" ]]; then
                _values "variable names" ${(f)"$(dotenv -f "$RAMDISK_STATE" list-keys)"}
              fi
          ;;
          up)
            _arguments \
              '--name:name:' \
              '--size-mb:size-mb:' \
              '--link-path:link-path:_files' \
              '--help:help' \
              && return 0
          ;;
        esac
      ;;
    esac     
}