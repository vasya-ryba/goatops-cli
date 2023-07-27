# !/bin/bash

# env
DEFAULT_GOAT="meh"
GOAT_SOURCE="goatops.com"
COWS_DIR="${HOME}/.cowsay/cows"
declare -A moods=(
  ["i"]="t"
  ["em"]="s"
)

check_dependencies() {
	PACKAGES=1
	which cowsay > /dev/null 2>&1 || {
	       	echo -e "Please install \033[1mcowsay\033[0m utility" && 
		PACKAGES=0
	}
	which xmllint > /dev/null 2>&1 || {
                echo -e "Please install \033[1mxmllint\033[0m utility" &&
                PACKAGES=0
        }
	if [ ! $PACKAGES ]; then exit 2; fi

	mkdir -p $COWS_DIR
	if [ ! -f "${COWS_DIR}/goat.cow" ]; then 
                  cat << 'EOF' > ${COWS_DIR}/goat.cow
#
#	CodeGoat.io: https://github.com/danyshaanan/goatsay
#
$the_cow = <<EOC;
        $thoughts
         $thoughts
          )__(
         '|$eyes|'________/
          |__|         |
           V ||"""""""||
             ||       ||

EOC
EOF
	fi
}

# Detect mood and print phrase
print_goat() {
	WISDOM=${1}

	# If goat is silent, say default wisdom
	WCUT=$(echo ${WISDOM} | tr -d " \t\n\r")
	if [[ -z $WCUT ]]; then
		WISDOM=${DEFAULT_GOAT}
	fi

	# Translate tags to goat moods
	OPTIONS=""
	for tag in "${!moods[@]}"; do
		if [[ $WISDOM == *"<$tag>"* ]]; then
			OPTIONS="${moods[$tag]}"
			WISDOM=${WISDOM//"<${tag}>"/}
			WISDOM=${WISDOM//"</${tag}>"/}
		fi
	done

	COWPATH=${COWS_DIR} cowsay -${OPTIONS}f goat ${WISDOM}
}

# Default goat wisdom
trap 'if [[ $? -eq 23 ]]; then print_goat ${DEFAULT_GOAT}; exit 0; fi' EXIT

# Check if dependencies are installed
check_dependencies

# Download goat wisdom list. If website is not available, set to default
GOATHTML=$(curl -sL ${GOAT_SOURCE} | xmllint --html --xpath "//div[@id='container']/ul/li" - 2>/dev/null) || exit 23

# Count number of wisdoms
GCOUNT=$(xmllint --html --xpath "count(//li)" 2>/dev/null - <<<"${GOATHTML}")

# Select random element from the list 
GRAND=$(( ($RANDOM % $GCOUNT) + 1))

# Get its contains
GOAT=$(xmllint --html --xpath '(//li)['"${GRAND}"']' 2>/dev/null - <<<"${GOATHTML}")

print_goat "${GOAT:4:-5}"
