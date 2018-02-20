set -eEuo pipefail
shopt -s lastpipe

config_dir=../tmp/test/config
tmp_dir=../tmp/test/tmp
test_data_dir=../tmp/test/testdata

source ../../src/common.bash
source ../../src/save.bash
source ../../src/apply.bash
source ../../src/check.bash
source ../../src/helpers.bash

LogEnter 'Running test case %s...\n' "$(Color C "$(basename "$0" .sh)")"
LogEnter 'Setting up test suite...\n'

rm -rf   "$config_dir" "$tmp_dir" "$test_data_dir"
mkdir -p "$config_dir" "$tmp_dir" "$test_data_dir"

touch "$test_data_dir"/packages.txt

# Mocked system introspection programs

function pacman() {
	set -e
	local command=
	local subcommand=
	local args=()
	local opt_quiet=false
	local opt_explicit=false
	local opt_native=false
	local opt_foreign=false

	local arg
	for arg in "$@"
	do
		case "$arg" in
			--query)
				command=query
				;;
			--list)
				subcommand=list
				;;
			--quiet)
				opt_quiet=true
				;;
			--explicit)
				opt_explicit=true
				;;
			--native)
				opt_native=true
				;;
			--foreign)
				opt_foreign=true
				;;
			--*)
				FatalError 'Unknown mocked pacman switch %s\n' "$(Color Y "$arg")"
				;;
			*)
				args+=("$arg")
		esac
	done

	case "$command" in
		query)
			case "$subcommand" in
				'')
					$opt_quiet || FatalError 'Mocked pacman --query without --quiet\n'
					$opt_explicit || FatalError 'Mocked pacman --query without --explicit\n'

					local name kind inst_as
					while IFS=$'\t' read -r name kind inst_as
					do
						if $opt_native && [[ "$kind" != native ]]
						then
							continue
						fi

						if $opt_foreign && [[ "$kind" != foreign ]]
						then
							continue
						fi

						if $opt_explicit && [[ "$inst_as" != explicit ]]
						then
							continue
						fi

						printf "%s\n" "$name"
					done < "$test_data_dir"/packages.txt
					;;
				list)
					: # TODO
					;;
				*)
					FatalError 'Unknown --query subcommand %s\n' "$subcommand"
					;;
			esac
			;;
		*)
			FatalError 'Unknown command %s\n' "$command"
			;;
	esac
}

function sudo() {
	"$@"
}

function sh() {
	test $# -eq 2 || FatalError 'Expected two sh arguments\n'
	test "$1" == '-c' || FatalError 'Expected -c as first sh argument\n'
	eval "$2"
}

function stdbuf() {
	test $# -gt 2 || FatalError 'Expected two or more stdbuf arguments\n'
	test "$1" == '-o0' || FatalError 'Expected -o0 as first stdbuf argument\n'
	shift
	"$@"
}

function find() {
	if [[ $1 != / ]]
	then
		command "find" "$@"
	else
		: # TODO
	fi
}

function paccheck() {
	: # TODO
}

# Test case configuration functions

function TestPhase_Setup() {
	LogLeave
	LogEnter 'Setting up test case...\n'
}

function TestPhase_Run() {
	LogLeave
	LogEnter 'Running test...\n'
}

function TestPhase_Check() {
	LogLeave
	LogEnter 'Checking results...\n'
}

function TestDone() {
	LogLeave
	LogLeave
	Exit 0
}

function TestAddPackage() {
	local name=$1
	local kind=$2
	local inst_as=$3

	printf '%s %s %s\n' "$name" "$kind" "$inst_as" >> "$test_data_dir"/packages.txt
}
