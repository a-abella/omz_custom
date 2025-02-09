# Function to redact patterns in files based on YAML pattern definitions
function redact() {
    # Check for required tools
    if ! command -v yq >/dev/null 2>&1; then
        echo "Error: yq is required but not installed" >&2
        return 1
    fi
    
    if ! command -v rg >/dev/null 2>&1; then
        echo "Error: ripgrep (rg) is required but not installed" >&2
        return 1
    fi

    # Parse arguments
    local patterns_file=""
    local input_file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--patterns)
                if [[ -n "$2" ]]; then
                    patterns_file="$2"
                    shift 2
                else
                    echo "Error: -p/--patterns requires a file argument" >&2
                    return 1
                fi
                ;;
            *)
                if [[ -z "$input_file" ]]; then
                    input_file="$1"
                    shift
                else
                    echo "Error: unexpected argument: $1" >&2
                    return 1
                fi
                ;;
        esac
    done

    # Check if input file is provided and exists
    if [[ -z "$input_file" ]]; then
        echo "Error: INPUT_FILE is required" >&2
        return 1
    fi
    
    if [[ ! -f "$input_file" ]]; then
        echo "Error: INPUT_FILE does not exist: $input_file" >&2
        return 1
    fi

    # Set up pattern files
    local pattern_files=()
    if [[ -n "$patterns_file" ]]; then
        if [[ ! -f "$patterns_file" ]]; then
            echo "Error: patterns file does not exist: $patterns_file" >&2
            return 1
        fi
        pattern_files=("$patterns_file")
    else
        # Default to all yaml files in patterns directory
        pattern_files=( *.y*ml )
        if (( ${#pattern_files} == 0 )); then
            echo "Error: no pattern files found in default location" >&2
            return 1
        fi
    fi

    # Initialize result with input file content
    local result
    result=$(cat "$input_file")
    
    # Process each pattern file
    for pfile in "${pattern_files[@]}"; do
        echo "Processing patterns from: $pfile" >&2
        
        pfile_content=$(cat "$pfile")
        
        # Extract and process each pattern using yq
        local pattern_count=$(yq '.patterns | length' <<< "$pfile_content")
        for ((i=0; i<pattern_count; i++)); do
            local name=$(yq ".patterns[$i].pattern.name" <<< "$pfile_content")
            local regex=$(yq ".patterns[$i].pattern.regex" <<< "$pfile_content")
            local confidence=$(yq ".patterns[$i].pattern.confidence" <<< "$pfile_content")
            
            # Skip if confidence is not high
            if [[ "$confidence" != "high" ]]; then
                echo "Skipping low confidence pattern: $name" >&2
                continue
            fi
            
            echo "Applying pattern: $name" >&2
            
            # Escape special characters in the replacement string
            local replacement="[REDACTED - ($name)]"
            replacement=${replacement//\\/\\\\}  # Escape backslashes first
            replacement=${replacement//\"/\\\"}  # Escape double quotes
            replacement=${replacement//\$/\\\$}  # Escape dollar signs
            replacement=${replacement//\`/\\\`}  # Escape backticks
            
            # Escape special characters in the regex pattern
            regex=${regex//\\/\\\\}  # Escape backslashes first
            regex=${regex//\"/\\\"}  # Escape double quotes
            regex=${regex//\$/\\\$}  # Escape dollar signs
            regex=${regex//\`/\\\`}  # Escape backticks
            
            # Perform the replacement in memory using properly escaped strings
            result=$(echo "$result" | rg --pcre2 --color=never -N -r "$replacement" --passthru -- "$regex")
        done
    done

    # Output final result to stdout
    echo "$result"
}