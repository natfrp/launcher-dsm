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
        return "至少输入 $2 字符";
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
        return "必须启用 Web UI 或配置远程管理";
    }
    if (remote_mgmt && arguments[0].length < 16) {
        return "启用远程管理后, 必须输入访问密钥";
    }
    return true;
}
EOF
}

######################################################################

PAGE_BASE_CONFIG=$(
    /bin/cat <<EOF
{
    "step_title": "配置启动器",
    "items": [{
            "type": "textfield",
            "desc": "基本配置",
            "subitems": [{
                "key": "$W_FIELD_TOKEN",
                "desc": "访问密钥",
                "validator": { "fn": "$(wizard_validate_token)" }
            }]
        },
        {
            "type": "singleselect",
            "desc": "Web UI",
            "subitems": [{
                "key": "$W_FIELD_WEBUI",
                "desc": "启用 (推荐)",
                "defaultValue": true,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_WEBUI_PASS 'true')" }
            }, {
                "key": "${W_FIELD_WEBUI}_off",
                "desc": "禁用 (必须配置远程管理)",
                "defaultValue": false,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_WEBUI_PASS 'false')" }
            }]
        },
        {
            "type": "textfield",
            "subitems": [{
                "key": "$W_FIELD_WEBUI_PASS",
                "desc": "Web UI 密码",
                "validator": { "fn": "$(wizard_validate_length_on $W_FIELD_WEBUI 8)" }
            }]
        },
        {
            "desc": "<i>* 推荐您总是启用 Web UI, 否则配置错误或重置访问密钥后将需要重新安装此软件包或登入 SSH 手动修改配置文件</i>"
        },
        {
            "type": "singleselect",
            "desc": "远程管理",
            "subitems": [{
                "key": "$W_FIELD_REMOTE_MGMT",
                "desc": "启用 (必须配置访问密钥)",
                "defaultValue": false,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_REMOTE_MGMT_KEY 'true')" }
            }, {
                "key": "${W_FIELD_REMOTE_MGMT}_off",
                "desc": "禁用",
                "defaultValue": true,
                "validator": { "fn": "$(wizard_disable_based_on $W_FIELD_REMOTE_MGMT_KEY 'false')" }
            }]
        },
        {
            "type": "textfield",
            "subitems": [{
                "key": "$W_FIELD_REMOTE_MGMT_KEY",
                "desc": "远程管理密码",
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
