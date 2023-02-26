#!/usr/bin/env bash

set -e

dependencies=(
    git
    wget
)

checkDependencies() {
    printf " [i] Checking Dependencies ! \n"
    for d in "${dependencies[@]}"; do
        if ! [ -x "$(command -v ${d})" ] ; then
            printf "     Err : %s %b ! \n" "Pls install" "${d}"
            exit 1
        fi
    done

    if [[ "${XDG_CURRENT_DESKTOP}" != "GNOME" ]]; then
        printf "     Err : %s ! \n" "Not GNOME"
        exit 1
    fi
}

getPkg() {
    git clone https://github.com/jakues/dotfiles/ ${HOME}/dotfiles -q
    
    local_bin="${HOME}/.local/bin"

    if ! [ -d ${local_bin} ]; then
        mkdir ${local_bin}
    fi

    cp ${HOME}/dotfiles/env ${local_bin}/myEnv
    source ${local_bin}/myEnv

    pkg=(
        btop
        cava
        gnome-tweak-tool
        kitty
        neofetch
        wofi
    )

    ${PRIN} " %b %s ..." "${INFO}" "Installing pkg" 
        dnf makecache -q -y || error "Pls check network !"
        for i in "${pkg[@]}"; do
            sudo dnf install ${i} -q -y || error "Failed to install ${i} !"
        done
    ${PRIN} "${DONE}\n"
}

setThemes() {
    export local_dir="${HOME}/.local"
    export local_files="${HOME}/dotfiles"
    
    themes=(
        "icons" # cursor theme
        "fonts" # fonts
        #"extensions" # extensions
    )

    for t in ${themes[@]}; do
        ${PRIN} " %b %s ..." "${INFO}" "Installing ${t}"
            cp -arf ${local_files}/${t} ${local_dir}/share
        ${PRIN} "${TICK}\n"
    done

    cfg=(
        btop
        cava
        chsh
        kitty
        neofetch
        wofi
    )

    for c in ${cfg[@]}; do
        ${PRIN} " %b %s ..." "${INFO}" "Installing ${c} config"
            cp -arf ${local_dir}/config/${c} ${HOME}/.config/
        ${PRIN} "${TICK}\n"
    done

    ${PRIN} " %b %s ..." "${INFO}" "Installing gtk themes"
        if ! [ -d ${HOME}/.themes ]; then
            mkdir -p ${HOME}/.themes
        fi
        cp -arf ${local_dir}/themes/* ${HOME}/.themes/
    ${PRIN} "${TICK}\n"
}

getAddons() {
    local_dir="${HOME}/.local/bin"
    source ${local_dir}/myEnv

    # install nitch
    nitchRepo="https://github.com/unxsh/nitch/releases/download/0.1.6/nitchNerd"
    ${PRIN} " %b %s ..." "${INFO}" "Installing nitch"
        get ${local_dir}/nitch ${nitchRepo} || error "Failed to install nitch"
        chmod +x ${local_dir}/nitch
    ${PRIN} "${TICK}\n"

    # install tty-clock
    ${PRIN} " %b %s ..." "${INFO}" "Installing tty-clock"
        cp ${HOME}/dotfiles/tty-clock ${local_dir}
        chmod +x ${local_dir}/tty-clock
    ${PRIN} "${TICK}\n"

    # install ohmyzsh
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    chsh -s $(which zsh)
    cat > ${HOME}/.zshrc << EOF
export PATH=$PATH:${HOME}/.local/bin
alias clock="tty-clock -c -C 7"
EOF
}

main() {
    checkDependencies
    getPkg
    setThemes
    getAddons
}

main