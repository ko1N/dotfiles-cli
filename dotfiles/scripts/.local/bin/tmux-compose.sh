#!/bin/bash

# tmux-compose: A tool to define and manage tmux sessions using YAML configuration
# Similar to docker-compose but for tmux sessions

set -e

# Check if yq is installed (for YAML parsing)
if ! command -v yq &> /dev/null; then
    echo "Error: yq is required but not installed."
    echo "Please install yq first: https://github.com/mikefarah/yq#install"
    exit 1
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is required but not installed."
    echo "Please install tmux first."
    exit 1
fi

# Default config file
CONFIG_FILE="tmux-compose.yml"

# Function to display usage information
usage() {
    echo "Usage: tmux-compose [OPTIONS] COMMAND"
    echo ""
    echo "Options:"
    echo "  -f, --file FILE     Specify an alternate compose file (default: tmux-compose.yml)"
    echo "  -h, --help          Show this help message and exit"
    echo ""
    echo "Commands:"
    echo "  up                  Create and start tmux sessions defined in the config"
    echo "  down                Stop and remove tmux sessions defined in the config"
    echo "  ls                  List running tmux sessions"
    echo ""
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            COMMAND="$1"
            shift
            break
            ;;
    esac
done

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '$CONFIG_FILE' not found."
    exit 1
fi

# Function to create tmux sessions from config
create_sessions() {
    # Get the number of sessions defined in the config
    SESSION_COUNT=$(yq '.sessions | length' "$CONFIG_FILE")
    
    # Loop through each session
    for ((i=0; i<$SESSION_COUNT; i++)); do
        SESSION_NAME=$(yq ".sessions[$i].name" "$CONFIG_FILE" | sed 's/^"//;s/"$//')
        
        # Check if session already exists
        if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
            echo "Session '$SESSION_NAME' already exists, skipping..."
            continue
        fi
        
        echo "Creating session: $SESSION_NAME"
        
        FIRST_WINDOW_NAME=$(yq ".sessions[$i].windows[0].name // \"window1\"" "$CONFIG_FILE" | sed 's/^"//;s/"$//')
        FIRST_WINDOW_CMD=$(yq -r ".sessions[$i].windows[0].command // \"\"" "$CONFIG_FILE")
        
        # Create the session with the first window
        tmux new-session -d -s "$SESSION_NAME" -n "$FIRST_WINDOW_NAME"
        
        # Debug output
        echo "  First window created with name: $FIRST_WINDOW_NAME"
        
        # If there's a command for the first window, run it
        if [ -n "$FIRST_WINDOW_CMD" ] && [ "$FIRST_WINDOW_CMD" != "null" ]; then
            tmux send-keys -t "$SESSION_NAME:$FIRST_WINDOW_NAME" "$FIRST_WINDOW_CMD" C-m
        fi
        
        # Get the number of windows for this session
        WINDOW_COUNT=$(yq ".sessions[$i].windows | length" "$CONFIG_FILE")
        
        # Skip the first window (index 0) as we've already created it
        for ((w=1; w<$WINDOW_COUNT; w++)); do
            WINDOW_NAME=$(yq ".sessions[$i].windows[$w].name // \"window$(($w+1))\"" "$CONFIG_FILE" | sed 's/^"//;s/"$//')
            WINDOW_CMD=$(yq -r ".sessions[$i].windows[$w].command // \"\"" "$CONFIG_FILE")
            
            echo "  Creating window: $WINDOW_NAME"
            
            # Create the window with the specified name
            tmux new-window -t "$SESSION_NAME:" -n "$WINDOW_NAME"
            
            # Debug output
            echo "    Window created with name: $WINDOW_NAME"
            
            # If there's a command for this window, run it
            if [ -n "$WINDOW_CMD" ] && [ "$WINDOW_CMD" != "null" ]; then
                tmux send-keys -t "$SESSION_NAME:$WINDOW_NAME" "$WINDOW_CMD" C-m
            fi
            
            # Check if this window has splits (panes)
            PANE_COUNT=$(yq ".sessions[$i].windows[$w].panes | length // 0" "$CONFIG_FILE")
            
            # If there are panes defined, create them
            if [ "$PANE_COUNT" -gt 0 ]; then
                for ((p=0; p<$PANE_COUNT; p++)); do
                    PANE_CMD=$(yq -r ".sessions[$i].windows[$w].panes[$p].command // \"\"" "$CONFIG_FILE")
                    PANE_SPLIT=$(yq ".sessions[$i].windows[$w].panes[$p].split // \"vertical\"" "$CONFIG_FILE" | sed 's/^"//;s/"$//')
                    
                    # Skip the first pane as it's already created with the window
                    if [ "$p" -gt 0 ]; then
                        if [ "$PANE_SPLIT" = "horizontal" ]; then
                            # Horizontal split creates a pane side by side (splits horizontally)
                            tmux split-window -h -t "$SESSION_NAME:$WINDOW_NAME"
                        else
                            # Vertical split creates a pane below (splits vertically)
                            tmux split-window -v -t "$SESSION_NAME:$WINDOW_NAME"
                        fi
                    fi
                    
                    # If there's a command for this pane, run it
                    if [ -n "$PANE_CMD" ] && [ "$PANE_CMD" != "null" ]; then
                        # For the first pane, we need to target it specifically
                        if [ "$p" -eq 0 ]; then
                            tmux send-keys -t "$SESSION_NAME:$WINDOW_NAME.0" "$PANE_CMD" C-m
                        else
                            # The newly created pane becomes the active one
                            tmux send-keys -t "$SESSION_NAME:$WINDOW_NAME" "$PANE_CMD" C-m
                        fi
                    fi
                done
                
                # Arrange panes in a layout if specified
                LAYOUT=$(yq ".sessions[$i].windows[$w].layout // \"\"" "$CONFIG_FILE" | sed 's/^"//;s/"$//')
                if [ -n "$LAYOUT" ] && [ "$LAYOUT" != "null" ]; then
                    echo "    Applying layout: $LAYOUT"
                    
                    # Give tmux a moment to settle
                    sleep 0.2
                    
                    # Select the first pane before applying layout
                    tmux select-pane -t "$SESSION_NAME:$WINDOW_NAME.0" 2>/dev/null
                    
                    # Apply the layout
                    tmux select-layout -t "$SESSION_NAME:$WINDOW_NAME" "$LAYOUT" 2>/dev/null || \
                    echo "    Warning: Failed to apply layout '$LAYOUT'"
                fi
            fi
        done
        
        # Select the first window
        tmux select-window -t "$SESSION_NAME:0"
    done
    
    echo "All sessions created successfully!"
    echo "Use 'tmux attach -t SESSION_NAME' to connect to a session."
}

# Function to stop and remove tmux sessions
stop_sessions() {
    # Get the number of sessions defined in the config
    SESSION_COUNT=$(yq '.sessions | length' "$CONFIG_FILE")
    
    # Loop through each session
    for ((i=0; i<$SESSION_COUNT; i++)); do
        # Get session name and remove quotes if present
        SESSION_NAME=$(yq ".sessions[$i].name" "$CONFIG_FILE" | sed 's/^"//;s/"$//')
        
        # Check if session exists
        if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
            echo "Stopping session: $SESSION_NAME"
            tmux kill-session -t "$SESSION_NAME"
        else
            echo "Session '$SESSION_NAME' not found, skipping..."
        fi
    done
    
    echo "All sessions stopped!"
}

# Function to list running tmux sessions
list_sessions() {
    echo "Running tmux sessions:"
    tmux list-sessions 2>/dev/null || echo "No active tmux sessions."
}

# Execute the specified command
case "$COMMAND" in
    up)
        create_sessions
        ;;
    down)
        stop_sessions
        ;;
    ls)
        list_sessions
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        usage
        ;;
esac

