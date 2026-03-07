# .zprofile is for login shell config

# Add A Welcome Slogan
if [[ ( -z "${WELCOME_SLOGAN_ONESHOT:-}" ) && ( -n "${TERM_PROGRAM:-}" ) ]]; then
    figlet -f "/opt/homebrew/share/figlet/fonts/figlet-fonts/ANSI Shadow" "S.W.Q Welcome!" | lolcat -a -d 1
    export WELCOME_SLOGAN_ONESHOT=1
fi

