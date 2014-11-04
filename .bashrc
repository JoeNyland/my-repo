# Generate a random alphanumeric string. Takes string length as an argument, defaults to 32 characters.
getrandomstring() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

# Strips the protocol prefix and path suffix from a URL, leaving just the FQDN
stripurl() {
    # Strip off the protocol identifier, so everything from start of $url to '://'
    url=$(echo $1 | sed -e 's/^[a-zA-Z0-9]*:\/\///g')
    # Chop the path off the end, from the first '/'
    echo $url | sed -e 's/\/.*//g'
}

# Return the current public IP
getpublicip() {
    curl icanhazip.com
}

# Set a clearer sudo prompt
alias sudo='sudo '
alias sudo='sudo -p "[sudo] password for %p: "'

# The usual Rsync options
alias rsync='rsync -avPh'
alias rsync-dry='rsync -n'

# Simple bell
alias bell='tput bel'

# Enable shopts
shopt -s checkjobs
shopt -s cdspell
shopt -s dirspell

# Configure Bash history
HISTTIMEFORMAT='%c '
HISTSIZE=100000
HISTFILESIZE=100000

