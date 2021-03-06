# aconfmgr test suite support code.
# Sourced by test case scripts.

# aconfmgr tests work by:
# - mocking operations that inspect and modify the system (see
#   ./lib-mocks.bash)
# - helper functions that set up or inspect aconfmgr's configuration /
#   environment / results (see ./lib-funcs.bash)

source ./lib-init.bash

source ../../src/common.bash
source ../../src/save.bash
source ../../src/apply.bash
source ../../src/check.bash
source ../../src/helpers.bash

LogEnter 'Running test case %s...\n' "$(Color C "$test_name")"
LogEnter 'Setting up test suite...\n'

rm -rf   "$config_dir" "$tmp_dir" "$test_data_dir"
mkdir -p "$config_dir" "$tmp_dir" "$test_data_dir"

touch "$test_data_dir"/packages.txt
mkdir -p "$test_data_dir"/packages

source ./lib-mocks.bash
source ./lib-funcs.bash

# Don't use diff --color=auto when it's not available
if test -v BUILD_BASH && ! diff --color=auto /dev/null /dev/null 2>/dev/null
then
	diff_opts=(diff)
fi
