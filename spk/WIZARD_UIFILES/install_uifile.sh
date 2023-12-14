#!/bin/bash

quote_json() {
    sed -e 's|\\|\\\\|g' -e 's|\"|\\\"|g'
}

page_append() {
    if [ -z "$1" ]; then
        echo "$2"
    elif [ -z "$2" ]; then
        echo "$1"
    else
        echo "$1,$2"
    fi
}

#### Fields ##########################################################

W_FIELD_TOKEN="wizard_token"
W_FIELD_WEBUI="wizard_webui"
W_FIELD_WEBUI_PASS="wizard_webui_pass"
W_FIELD_REMOTE_MGMT="wizard_remote_mgmt"
W_FIELD_REMOTE_MGMT_KEY="wizard_remote_mgmt_key"

#### Validators ######################################################

wizard_disable_based_on() {
    quote_json <<EOF
{
	var box = arguments[2].getComponent("$1");
	if (arguments[0] == $2) {
		box.setDisabled(false);
	} else {
		box.setValue("");
		box.setDisabled(true);
	}
	return true;
}
EOF
}

wizard_validate_length_on() {
    quote_json <<EOF
{
    if (arguments[2].getComponent("$1").checked && arguments[0].length < $2) {
        return "Input must be at least $2 characters long.";
    }
    return true;
}
EOF
}

wizard_validate_token() {
    quote_json <<EOF
{
	var webui = arguments[2].getComponent("$W_FIELD_WEBUI").checked;
    var remote_mgmt = arguments[2].getComponent("$W_FIELD_REMOTE_MGMT").checked;

    if (!webui && !remote_mgmt) {
        return "You must enable at least one of Web UI and Remote Management";
    }
    if (remote_mgmt && arguments[0].length < 16) {
        return "Token must be configured when Remote Management is enabled";
    }
    return true;
}
EOF
}

######################################################################

PAGE_BASE_CONFIG=$(
    /bin/cat <<EOF
{
    "step_title": "Configure Launcher",
    "items": [{
            "type": "textfield",
            "desc": "Basic Configuration",
            "subitems": [{
                "key": "$W_FIELD_TOKEN",
                "desc": "Token",
                "validator": { "fn": "$(wizard_validate_token)" }
            }]
        },
        {
            "type": "singleselect",
            "desc": "Web UI",
            "subitems": [{
                "key": "$W_FIELD_WEBUI",
                "desc": "Enable (Recommended)",
                "defaultValue": true,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_WEBUI_PASS 'true')" }
            }, {
                "key": "${W_FIELD_WEBUI}_off",
                "desc": "Disable (Requires Remote Management)",
                "defaultValue": false,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_WEBUI_PASS 'false')" }
            }]
        },
        {
            "type": "textfield",
            "subitems": [{
                "key": "$W_FIELD_WEBUI_PASS",
                "desc": "Web UI Password",
                "validator": { "fn": "$(wizard_validate_length_on $W_FIELD_WEBUI 8)" }
            }]
        },
        {
            "desc": "<i>* It's always recommended to enable Web UI. Otherwise misconfiguration or token reset requires reinstalling the package or reconfigure via SSH.</i>"
        },
        {
            "type": "singleselect",
            "desc": "Remote Management",
            "subitems": [{
                "key": "$W_FIELD_REMOTE_MGMT",
                "desc": "Enable (Requires Token)",
                "defaultValue": false,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_REMOTE_MGMT_KEY 'true')" }
            }, {
                "key": "${W_FIELD_REMOTE_MGMT}_off",
                "desc": "Disable",
                "defaultValue": true,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_REMOTE_MGMT_KEY 'false')" }
            }]
        },
        {
            "type": "textfield",
            "subitems": [{
                "key": "$W_FIELD_REMOTE_MGMT_KEY",
                "desc": "Remote Management Key",
                "disabled": true,
                "validator": { "fn": "$(wizard_validate_length_on $W_FIELD_REMOTE_MGMT 8)" }
            }]
        }
    ]
}
EOF
)

main() {
    local install_page=""
    install_page=$(page_append "$install_page" "$PAGE_BASE_CONFIG")
    echo "[$install_page]" >"${SYNOPKG_TEMP_LOGFILE}"
}

main "$@"
