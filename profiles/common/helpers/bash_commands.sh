# encode to base64
function en64() {
  echo -n $1 | base64 -b0
}

# decode base64
function de64() {
  echo $1 | base64 -D
}

function nameTab() {
    echo -ne "\033]0;"$*"\007"
}

